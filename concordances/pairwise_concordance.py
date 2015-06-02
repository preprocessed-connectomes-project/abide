# pairwise_conordance.py
#
# Author: Daniel Clark, 2015

'''
This module uses functions that download and analyze S3
objects and compute pair-wise concordances

Usage: python pairwise_concordance -b <base_dir> -i <index> -o <output_dir>
'''

# Calculate concordance correlation coefficient
def concordance(x, y):
    '''
    Return the concordance correlation coefficient as defined by
    Lin (1989)

    Parameters
    ----------
    x : list or array
        a list of array of length N of numbers
    y : list or array
        a list of array of length N of numbers

    Returns
    -------
    rho_c : numpy.float32
        the concordance value as a float
    '''

    # Import packages
    import numpy as np

    # Usage errors check
    x_shape = np.shape(x)
    y_shape = np.shape(y)
    if len(x_shape) != 1 or len(y_shape) != 1:
        err_msg = 'Inputs must be 1D lists or arrays.'
        raise ValueError(err_msg)
    elif x_shape != y_shape:
        err_msg = 'Length of the two inputs must be equal.\n'\
                'Length of x: %d\nLength of y: %d' % (len(x), len(y))
        raise ValueError(err_msg)

    # Init variables
    x_arr = np.array(x).astype('float64')
    y_arr = np.array(y).astype('float64')

    # Get pearson correlation
    rho = np.corrcoef(x_arr, y_arr)[0][1]

    # Get stdevs
    sigma_x = np.std(x_arr)
    sigma_y = np.std(y_arr)

    # Get means
    mu_x = np.mean(x_arr)
    mu_y = np.mean(y_arr)

    # Comput condordance
    rho_c = (2*rho*sigma_x*sigma_y) /\
            (sigma_x**2 + sigma_y**2 + (mu_x-mu_y)**2)

    # Return variables
    return rho_c


# Compare niftis and insert into dataframe
def compare_and_insert(base_dir, comparison, data_frame):
    '''
    Function to compare two nifti files based on a list of comparison
    types; this comparison would then be logged into a data frame and
    the data frame would be returned with the new comparison entry

    Parameters:
    -----------
    base_dir : string
        base filepath to the directory containing the nifti files
    comparison : dictionary
        dictionary that has the comparison info, where the keys are:
        'comparison', 'derivative', 'pipeline', 'strategy', 'subject'
    data_frame : pandas.DataFrame
        data frame to insert the comparison entries into

    Returns
    -------
    data_frame : pandas.Dataframe object
        the input data frame appended with the new comparisons
    '''

    # Import packages
    import nibabel as nb
    import os

    # Init variables
    derivative = comparison['derivative']
    subject = comparison['subject']

    # If doing a pipeline comparison
    if comparison['pipeline'] == 'N/A':
        pipelines = comparison['comparison']
        strategy = comparison['strategy']
        img1_pre = os.path.join(base_dir, pipelines[0], strategy)
        img2_pre = os.path.join(base_dir, pipelines[1], strategy)
    # Otherwise if doing a strategy comparison
    elif comparison['strategy'] == 'N/A':
        strategies = comparison['comparison']
        pipeline = comparison['pipeline']
        img1_pre = os.path.join(base_dir, pipeline, strategies[0])
        img2_pre = os.path.join(base_dir, pipeline, strategies[1])

    # Form the complete file paths
    img1_file = os.path.join(img1_pre, derivative,
                             subject + '_' + derivative + '.nii.gz')
    img2_file = os.path.join(img2_pre, derivative,
                             subject + '_' + derivative + '.nii.gz')

    # Extract image paths from features dictionary
    img1 = nb.load(img1_file).get_data()
    img2 = nb.load(img2_file).get_data()

    # Check the dimensionalities
    if img1.shape != img2.shape:
        err_msg = '%s and %s are of different dimensions!' % \
                (img1_file, img2_file)
        raise Exception(err_msg)
    # Is it three dimensional
    elif len(img1.shape) == 3:
        # Compute concordance
        rho_c = concordance(img1.flatten(), img2.flatten())
    # Is it four dimensional
    elif len(img1.shape) == 4:
        rho_c = []
        # Compute concordance for each spatial image
        for dim in range(img1.shape[3]):
            rho_cc = concordance(img1[:,:,:,dim].flatten(), img2[:,:,:,dim].flatten())
            rho_c.append(rho_cc)
    # Otherwise, return dimensionality error
    else:
        err_msg = 'Dimensionality of images cannot be processed!\n'\
                  'Dim of %s: %d\nDim of %s:%d' \
                  % (img1_file, len(img1.shape), img2_file, len(img2.shape))
        raise Exception(err_msg)

    print 'concordance is:\n', rho_c
    # Insert comparisons into the database
    # If multiple comparisons, multiple spatial images
    if type(rho_c) == list:
        for dim in range(len(rho_c)):
            entry = [rho_c[dim], str(comparison['comparison']),
                     derivative + '_' + str(dim), comparison['pipeline'],
                     comparison['strategy'], subject]
            data_frame.loc[len(data_frame)] = entry
    # Single comparison
    else:
        entry = [rho_c, str(comparison['comparison']), derivative,
                 comparison['pipeline'], comparison['strategy'], subject]
        data_frame.loc[len(data_frame)] = entry

    # Return the populated data frame
    return data_frame


# Create the list of all possible comparisons
def create_comparisons_list(subjects, derivatives, strategies, pipelines):
    '''
    Function to create the pairwise cross-strategy and cross-pipeline
    comparisons list

    Parameters
    ----------
    subjects : list [str]
        a list of subject identifiers
    derivatives : list [str]
        a list of derivatives
    strategies : list [str]
        a list of strategies
    pipelines : list [str]
        a list of pipelines

    Returns
    -------
    comparisons : list [dict]
        a list of comparisons, which are dictionaries
    pipe_comps : list [tuple]
        a list of two-element tuples of the pairwise pipeline
        comparisons
    strat_comps : list [tuple]
        a list of two-element tuples of the pairwise strategy
        comparisons
    '''

    # Import packages
    import itertools

    # Init variables
    comparisons = []
    # Get pairwise combinations
    pipe_comps = [pipe_comp for pipe_comp in \
                      itertools.combinations(pipelines, 2)]
    strat_comps = [strat_comp for strat_comp in \
                      itertools.combinations(strategies, 2)]

    # For each subject
    for subj in subjects:
        # For each derivative
        for deriv in derivatives:
            # For each strategy
            for strat in strategies:
                for pipe_comp in pipe_comps:
                    comp_dict = {}
                    comp_dict['subject'] = subj
                    comp_dict['strategy'] = strat
                    comp_dict['pipeline'] = 'N/A'
                    comp_dict['derivative'] = deriv
                    comp_dict['comparison'] = pipe_comp
                    comparisons.append(comp_dict)
            # For each pipeline
            for pipe in pipelines:
                for strat_comp in strat_comps:
                    comp_dict = {}
                    comp_dict['subject'] = subj
                    comp_dict['strategy'] = 'N/A'
                    comp_dict['pipeline'] = pipe
                    comp_dict['derivative'] = deriv
                    comp_dict['comparison'] = strat_comp
                    comparisons.append(comp_dict)

    # Return the comparisons list
    return comparisons, pipe_comps, strat_comps


# Main function
def main(base_dir, comparisons_list, index, output_dir, stride):
    '''
    Function to gather nifti files from multi-pipeline, multi-strategy
    MRI/fMRI data pre-processing and compute pair-wise concordance
    and finally storing the results in a data frame that it is written
    to disk as a csv

    Data should be organized in the form:

    base_dir/pipeline/strategy/derivative/subject_derivative.nii.gz

    Parameters
    ----------
    base_dir : string
        base filepath to the directory containing the nifti files
    comparisons_list : list [dict]
        a list of comparisons, which are dictionaries
    index : integer
        index of the comparisons_list to choose the comparison from
    output_dir : string
        base directory where to write the output data frames
    stride : integer
        amount of comparisons to run and save into single csv file

    Returns
    -------
    new_df : pandas.DataFrame object
        dataframe containing the comparison made
    csv_path : string
        filepath to the local data frame csv to save
    '''

    # Import packages
    import os
    import pandas as pd
    import yaml

    # Init variables
    st_idx = stride*index
    fn_idx = st_idx + stride

    # Iterate through the indices for the stride length
    for idx in range(st_idx, fn_idx):
        comparison = comparisons_list[idx]
        print comparison

        # If first comparison, init columns to be
        # ['concordance', 'comparison', 'derivative', 'pipeline', 'strategy', 'subject']
        if idx == st_idx:
            cols = ['concordance']
            cols.extend(sorted(comparison.keys()))
            data_frame = pd.DataFrame(columns=cols)

        # Do the comparison and insert into dataframe
        try:
            data_frame = compare_and_insert(base_dir, comparison, data_frame)
        except Exception as exc:
            print 'ran in to error while processing comparison number %d.\n'\
                  'error: %s' % (index, exc)
            continue

    # Save the data frame to a csv in output_prefix/subject dir
    csv_path = os.path.join(output_dir, '%d-%d.csv' % (st_idx, fn_idx))

    # Check if directory already exists or not
    subj_dir = os.path.dirname(csv_path)
    if not os.path.exists(subj_dir):
        os.makedirs(subj_dir)

    # Return the data frame and csv path
    return data_frame, csv_path


# Main executable
if __name__ == '__main__':

    # Import packages
    import argparse
    import os
    import yaml

    # Init variables
    stride = 528

    # Init argparser
    parser = argparse.ArgumentParser(description=__doc__)
    # Required arguments
    parser.add_argument('-b', '--base_dir', nargs=1, required=True,
                        help='Base directory where nifti files are stored. '\
                             '/<base_dir>/pipeline/strategy/derivative/file')
    parser.add_argument('-i', '--index', nargs=1, required=True,
                        help='Integer index of the comparisons list to '\
                             'analyze and store in data frame.')
    parser.add_argument('-s', '--sublist_path', nargs=1, required=True,
                        help='Filepath to yaml file of subject ids.')
    parser.add_argument('-o', '--output_dir', nargs=1, required=True,
                        help='Base output directory to store all of the '\
                             'comparison files. /<output_dir>/subject/df.csv')

    # Get arguments
    args = parser.parse_args()

    # Init argument variables
    base_dir = os.path.abspath(args.base_dir[0])
    index = int(args.index[0]) - 1

    sublist_path = os.path.abspath(args.sublist_path[0])
    output_dir = os.path.abspath(args.output_dir[0])

    # Init values to generate comparisons list
    derivatives = ['alff', 'degree_binarize', 'degree_weighted',
                   'dual_regression', 'eigenvector_binarize',
                   'eigenvector_weighted', 'falff', 'func_mean',
                   'lfcd', 'reho', 'vmhc']
    pipelines = ['ccs', 'cpac', 'dparsf', 'niak']
    strategies = ['filt_global', 'filt_noglobal',
                  'nofilt_global', 'nofilt_noglobal']

    subjects = yaml.load(open(sublist_path, 'r'))

    # Get comparisons list
    comparisons_list, pipe_comps, strat_comps = \
            create_comparisons_list(subjects, derivatives, strategies, pipelines)

    # Call main function
    data_frame, csv_path = main(base_dir, comparisons_list, index, output_dir,
                                stride)

    # Save dataframe
    data_frame.to_csv(csv_path)
