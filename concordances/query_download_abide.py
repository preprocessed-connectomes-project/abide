# query_download_abide.py
#
# Author: Daniel Clark, 2015

'''
This module provides functionality to query a dataframe and download
imaging data for analysis
'''

# Extract comparison items from string tuple
def extract_comparisons(str_tuple):
    '''
    '''

    # Init variables
    comps_list = []
    comps = str_tuple.split(', ')

    # Strip out extraneous characters
    comps_list.append(comps[0].lstrip('(\'').rstrip('\''))
    comps_list.append(comps[1].rstrip('\')').lstrip('\''))

    # Return comparisons as list
    return comps_list


# Download data from S3
def s3_download(files_list, local_dir):
    '''
    '''

    # Import packages
    import boto
    import os
    from CPAC.AWS import fetch_creds

    # Init variables
    local_list = []
    bucket = fetch_creds.return_bucket('fcp-indi', '/home/ubuntu/secure-creds/aws-keys/fcp-indi-keys2.csv')

    # Pull file keys
    for img_file in files_list:
        # Get file key on S3
        s3_key = bucket.get_key(img_file)
        key_name = str(s3_key.name)

        # Get local name
        key_name_dash = key_name.replace('/', '-')
        local_name = key_name_dash.replace('data-Projects-ABIDE_Initiative-Outputs-',
                                      local_dir)

        # Check dirs and make dirs
        dirs_name = os.path.dirname(local_name)
        if not os.path.exists(dirs_name):
            os.makedirs(dirs_name)

        # Download data
        print 'Saving %s to %s...' % (key_name, local_name)
        s3_key.get_contents_to_filename(local_name)

        # Append local list
        local_list.append(local_name)

    # Return local list
    return local_list


# Return s3 filepaths from dataframe entry
def return_filepaths_from_entry(df_entry):
    '''
    '''

    # Import packages
    import os

    # Init variables
    files_list = []
    prefix = 'data/Projects/ABIDE_Initiative/Outputs'

    # Get meta data
    pipeline = df_entry.pipeline
    strategy = df_entry.strategy
    derivative = df_entry.derivative
    subject = df_entry.subject

    # See if cross-strat or cross-pipe
    if type(strategy) is str:
        pipelines = extract_comparisons(df_entry.comparison)
        for pipeline in pipelines:
            img_file = os.path.join(prefix, pipeline, strategy, derivative,
                                    subject + '_' + derivative + '.nii.gz')
            files_list.append(img_file)
    elif type(pipeline) is str:
        strategies = extract_comparisons(df_entry.comparison)
        for strategy in strategies:
            img_file = os.path.join(prefix, pipeline, strategy, derivative,
                                    subject + '_' + derivative + '.nii.gz')
            files_list.append(img_file)
    else:
        err_msg = 'Expecting either strategy or pipeline to be a string!'
        raise TypeError(err_msg)

    # Return filepaths
    return files_list


# Download and compare
def download_and_compare(df_entry, local_dir):
    '''
    '''

    # Import packages
    from pairwise_concordance import concordance
    import nibabel as nb

    # Get filepaths to download
    print 'getting s3 filepaths...'
    s3_list = return_filepaths_from_entry(df_entry)
    print s3_list

    # Download data to local directory
    print 'downloading s3 files to %s...' % local_dir
    local_list = s3_download(s3_list, local_dir)
    print local_list

    # Compute concordances on data
    img1 = nb.load(local_list[0]).get_data()
    img2 = nb.load(local_list[1]).get_data()

    # Compute concordance
    print 'calculating concordance...'
    cc = concordance(img1.flatten(), img2.flatten())

    # Print concordance
    print 'Concordance between %s and %s is: %f' \
            % (local_list[0], local_list[1], cc)
