# Import packages
# CPAC
from CPAC.AWS import aws_utils, fetch_creds
from CPAC.utils.configuration import Configuration
from CPAC.network_centrality.resting_state_centrality import *
from CPAC.network_centrality.utils import merge_lists
from CPAC.network_centrality.z_score import get_cent_zscore
from CPAC.utils.utils import set_gauss
# nipype
import nipype.pipeline.engine as pe
import nipype.interfaces.fsl as fsl
import nipype.interfaces.utility as util
# system
import glob
from multiprocessing import Process
import os
import shutil
import sys
import yaml


# Make and execute workflow
def make_workflow(in_file, strat_name, sub_id, c, local_prefix):
    # Init entire worklfow
    eigen_wf = pe.Workflow('eigen_wf_%s_%s' % (sub_id, strat_name))

    # Input node - resample to template
    resample_func_to_template = pe.Node(interface=fsl.FLIRT(),
                                           name='resample_func_to_template')
    resample_func_to_template.inputs.interp = 'trilinear'
    resample_func_to_template.inputs.apply_xfm = True
    resample_func_to_template.inputs.in_matrix_file = c.identityMatrix

    # Main centrality node
    eigen_centrality = create_resting_state_graphs(allocated_memory=16)


    ## Connect nodes (input -> centrality)
    eigen_wf.connect(resample_func_to_template, 'out_file',
                     eigen_centrality, 'inputspec.subject')

    # Init merge node for appending method output lists to one another
    merge_node = pe.Node(util.Function(input_names=['deg_list',
                                                    'eig_list',
                                                    'lfcd_list'],
                                  output_names = ['merged_list'],
                                  function = merge_lists),
                    name = 'merge_node')

    # Connect nodes (centrality -> merge_node)
    eigen_wf.connect(eigen_centrality, 'outputspec.centrality_outputs',
                     merge_node, 'eig_list')

    # If smoothing is required
    if c.fwhm != None :
        # Init inputnode for fwhm
        inputnode_fwhm = pe.Node(util.IdentityInterface(fields=['fwhm']),
                     name='fwhm_input')
        inputnode_fwhm.iterables = ("fwhm", c.fwhm)

        # Init smoothing workflow
        smoothing = pe.MapNode(interface=fsl.MultiImageMaths(),
                               name='network_centrality_smooth',
                               iterfield=['in_file'])

        smoothing.inputs.operand_files = c.templateSpecificationFile
        # Connect centrality outputs to smoothing
        eigen_wf.connect(merge_node, 'merged_list',
                         smoothing, 'in_file')
        eigen_wf.connect(inputnode_fwhm, ('fwhm', set_gauss),
                         smoothing, 'op_string')

    # Connect list of inputs to eigenvector workflow and run
    # Resample input data
    eigen_wf.inputs.resample_func_to_template.in_file = in_file
    eigen_wf.inputs.resample_func_to_template.reference = c.templateSpecificationFile
    # Centrality workflow
    eigen_centrality.inputs.inputspec.template = c.templateSpecificationFile
    eigen_centrality.inputs.inputspec.threshold = 0.001
    eigen_centrality.inputs.inputspec.method_option = 1
    eigen_centrality.inputs.inputspec.threshold_option = 0
    eigen_centrality.inputs.inputspec.weight_options = [True,True]

    # Z-score/smoothing arguments
    smoothing.operand_files = c.templateSpecificationFile

    # Run the workflow
    eigen_wf.base_dir = local_prefix
    eigen_wf.config['execution'] = {'hash_method' : 'timestamp', 'crashdump_dir' : '/home/ubuntu/eigen_run/crashes'}
    eigen_wf.run()

    # Return
    return eigen_wf


# Main function
def main(sub_idx):

    # Init variables
    bucket_name = 'fcp-indi'
    bucket_prefix = 'data/Projects/ABIDE_Initiative/Outputs/cpac/raw_outputs_rerun'
    config_file = '/home/ubuntu/abide_run/settings/pipeline_config_abide_rerun.yml'
    creds_path = '/home/ubuntu/secure-creds/aws-keys/fcp-indi-keys2.csv'
    local_prefix = '/mnt/eigen_run'
    sublist_file = '/home/ubuntu/abide_run/eig-subs1.yml'

    # Pull in bucket, config, and subject
    sublist = yaml.load(open(sublist_file, 'r'))
    subject = sublist[sub_idx]
    sub_id = subject.split('_')[-1]
    bucket = fetch_creds.return_bucket(creds_path, bucket_name)
    c = Configuration(yaml.load(open(config_file, 'r')))

    # Test to see if theyre already upload
    to_do = True

    if to_do:
        ## Collect functional_mni list from S3 bucket
        filt_global = 'pipeline_abide_rerun__freq-filter/%s_session_1/functional_mni/_scan_rest_1_rest/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/_compcor_ncomponents_5_selector_pc10.linear1.wm0.global1.motion1.quadratic1.gm0.compcor1.csf0/_bandpass_freqs_0.01.0.1/bandpassed_demeaned_filtered_antswarp.nii.gz' % sub_id
        filt_noglobal = filt_global.replace('global1','global0')
        nofilt_global = 'pipeline_abide_rerun/%s_session_1/functional_mni/_scan_rest_1_rest/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/_compcor_ncomponents_5_selector_pc10.linear1.wm0.global1.motion1.quadratic1.gm0.compcor1.csf0/residual_antswarp.nii.gz' % sub_id
        nofilt_noglobal = nofilt_global.replace('global1','global0')
        s3_functional_mni_list = [filt_global, filt_noglobal, nofilt_global, nofilt_noglobal]
        s3_functional_mni_list = [os.path.join(bucket_prefix, s) for s in s3_functional_mni_list]

        # Download contents to local inputs directory
        try:
            aws_utils.s3_download(bucket, s3_functional_mni_list, local_prefix=os.path.join(local_prefix, 'centrality_inputs'), bucket_prefix=bucket_prefix)
        except Exception as e:
            print 'Unable to find eigenvector centrality inputs for subject %s, skipping...' % sub_id
            print 'Error: %s' % e
            return

        # Build strat dict (dictionary of strategies and local input paths)
        strat_dict = {'filt_global' : os.path.join(local_prefix, 'centrality_inputs', filt_global),
                      'filt_noglobal' : os.path.join(local_prefix, 'centrality_inputs', filt_noglobal),
                      'nofilt_noglobal' : os.path.join(local_prefix, 'centrality_inputs', nofilt_noglobal),
                      'nofilt_global' : os.path.join(local_prefix, 'centrality_inputs', nofilt_global)}

        # Create list of processes
        proc_list = [Process(target=make_workflow, args=(in_name, strat, sub_id, c, local_prefix)) for strat, in_name in strat_dict.items()]

        # Iterate through processes and fire off
        for p in proc_list:
            p.start()

        for p in proc_list:
            if p.is_alive():
                p.join()

        # Gather outputs
        wfs = glob.glob(os.path.join(local_prefix, 'eigen_wf_%s_*' % sub_id))
        local_list = []
        for wf in wfs:
            for root, dirs, files in os.walk(wf):
                if files:
                    local_list.extend([os.path.join(root, f) for f in files])

        s3_list = [loc.replace(local_prefix, 'data/Projects/ABIDE_Initiative/Outputs/cpac/raw_outputs_eigen') for loc in local_list]

        aws_utils.s3_upload(bucket, local_list, s3_list)

        # And delete working directories
        try:
            for input_file in strat_dict.values():
                print 'removing input file %s...' % input_file
                os.remove(input_file % sub_id)
        except Exception as e:
            print 'Unable to remove input files'
            print 'Error: %s' %e

        work_dirs = glob.glob(os.path.join(local_prefix, 'eigen_wf_%s_*' % sub_id))

        for work_dir in work_dirs:
            print 'removing %s...' % work_dir
            shutil.rmtree(work_dir)
    else:
        print 'subject %s already processed and uploaded, skipping...' % sub_id


# Run main by default
if __name__ == '__main__':
    # Get subject index
    sub_idx = int(sys.argv[1]) - 1
    main(sub_idx)
