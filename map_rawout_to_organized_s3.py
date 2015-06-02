# map_rawout_to_organized_s3.py
#
# Author: Daniel Clark, 2015

'''
This module organizes outputs from the C-PAC pipeline into the ABIDE
pre-processed file structure
'''

# Main function
def main():
    '''
    This function runs the main routine
    '''
    # Import packages
    from CPAC.AWS import fetch_creds
    import os
    import yaml

    # Init variables
    creds_path = '/home/ubuntu/secure-creds/aws-keys/fcp-indi-keys2.csv'
    bucket = fetch_creds.return_bucket('fcp-indi', creds_path)
    bucket_prefix = 'data/Projects/ABIDE_Initiative/Outputs/cpac/raw_outputs_rerun'
    sub_fp = '/home/ubuntu/abide/preprocessing/yamls/subs_list.yml'
    sub_list = yaml.load(open(sub_fp, 'r'))
    example_subid = '0050002_session_1'

    # Populate list of files to link to
    #src_list = []
    #src_list = gather_files_tosort(src_list, bucket, bucket_prefix)

    # Derivatives dictionary {name: (no_files_per_strategy, filt_str)}
    strat_dict = {'nofilt_noglobal' : ['pipeline_abide_rerun', 'global0'],
                  'nofilt_global' : ['pipeline_abide_rerun', 'global1'],
                  'filt_noglobal' : ['pipeline_abide_rerun__freq-filter', 'global0'],
                  'filt_global' : ['pipeline_abide_rerun__freq-filter', 'global1']}

    derivs_dict = {'alff' : (1, 'alff_to_standard_smooth', 'nii.gz'),
                   'degree_binarize' : (1, 'centrality_outputs_smoothed', 'degree_centrality_binarize'),
                   'degree_weighted' : (1, 'centrality_outputs_smoothed', 'degree_centrality_weighted'),
                   'dual_regression' : (1, 'dr_tempreg_maps_zstat_stack_to_standard_smooth', 'nii.gz'),
                   'eigenvector_binarize' : (1, 'centrality_outputs_smoothed', 'eigenvector_centrality_binarize'),
                   'eigenvector_weighted' : (1, 'centrality_outputs_smoothed', 'eigenvector_centrality_weighted'),
                   'falff' : (1, 'falff_to_standard_smooth', 'nii.gz'),
                   'func_mask' : (1, 'functional_brain_mask_to_standard', 'nii.gz'),
                   'func_mean' : (1, 'mean_functional_in_mni', 'nii.gz'),
                   'func_preproc' : (1, 'functional_mni', '.nii.gz'),
                   'lfcd' : (1, 'centrality_outputs_smoothed', 'lfcd_binarize'),
                   'reho' : (1, 'reho_to_standard_smooth', 'nii.gz'),
                   'rois_aal' : (4, 'roi_timeseries', 'aal'),
                   'rois_cc200' : (4, 'roi_timeseries', 'CC200'),
                   'rois_cc400' : (4, 'roi_timeseries', 'CC400'),
                   'rois_dosenbach160' : (4, 'roi_timeseries', 'rois_3mm'),
                   'rois_ez' : (4, 'roi_timeseries', 'ez'),
                   'rois_ho' : (4, 'roi_timeseries', 'ho_'),
                   'rois_tt' : (4, 'roi_timeseries', 'tt'),
                   'vmhc' : (1, 'vmhc_fisher_zstd_zstat_map', 'nii.gz')}

    # Create error and output dictionaries
    out_dict = {k : {kk : [] for kk in derivs_dict.keys()} for k in strat_dict.keys()}
    err_dict = {k : {kk : [] for kk in derivs_dict.keys()} for k in strat_dict.keys()}

    # Iterate through strategies
    for strat, filts in strat_dict.items():
        print 'building %s...' % strat
        filt = filts[0]
        g_sig = filts[1]
        strat_prefix = os.path.join(bucket_prefix, filt, example_subid)
        # Iterate through derivatives
        for deriv, v in derivs_dict.items():
            num_files = v[0]
            deriv_folder = v[1]
            name_filter = v[2]
            deriv_prefix = os.path.join(strat_prefix, deriv_folder)
            keys_list = []
            for key in bucket.list(prefix=deriv_prefix):
                k_name = str(key.name)
                # If global signal regression was used or didnt need to be
                if (g_sig in k_name or 'global' not in k_name) and \
                        name_filter in k_name:
                    keys_list.append(k_name)
            # Grab only wanted results from keys
            if len(keys_list) == num_files:
                out_dict[strat][deriv] = [k for k in keys_list if '.nii.gz' in k or '.1D' in k][0]
            else:
                err_dict[strat][deriv] = keys_list
                print 'error in number of files!'

    # Go through dictionary and build paths
    mapping_dict = {}
    s = 1
    # For each subject
    for sub in sub_list:
        subid = sub.split('_')[-1] + '_session_1'
        print 'populating %s...%d' % (subid, s)
        # For each strategy
        for strat, deriv_dict in out_dict.items():
            strat_prefix = os.path.join(bucket_prefix, strat)
            # For each derivative, generate src and dst filepaths
            d = 0
            for deriv, filepath in deriv_dict.items():
                deriv_prefix = os.path.join(strat_prefix, deriv, sub + '_' + deriv)
                # Check extensions
                if filepath.endswith('.nii.gz'):
                    dst_path = deriv_prefix + '.nii.gz'
                elif filepath.endswith('.1D'):
                    dst_path = deriv_prefix + '.1D'
                else:
                    raise Exception('Bad extension type')
                # Get sub id from filepath
                src_path = filepath.replace(example_subid, subid)
                mapping_dict[src_path] = dst_path
                d += 1
            if d != 20:
                print d
                raw_input('not enough dervivs')
        s += 1

    # Return
    return out_dict, err_dict, mapping_dict


# Run main by default
if __name__ == '__main__':
    main()
