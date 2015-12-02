# download_abide_preproc.py
#
# Author: Daniel Clark, 2015

'''
This script downloads data from the Preprocessed Connetomes Project's
ABIDE Preprocessed data release and stores the files in a local
directory; users specify derivative, pipeline, strategy, and optionally
age ranges, sex, site of interest

Usage:
    python download_abide_preproc.py -d <derivative> -p <pipeline>
                                     -s <strategy> -o <out_dir>
                                     [-lt <less_than>] [-gt <greater_than>]
                                     [-x <sex>] [-t <site>]
'''


# Main collect and download function
def collect_and_download(derivative, pipeline, strategy, out_dir,
                         less_than, greater_than, site, sex):
    '''
    Function to collect and download images from the ABIDE preprocessed
    directory on FCP-INDI's S3 bucket

    Parameters
    ----------
    derivative : string
        derivative or measure of interest
    pipeline : string
        pipeline used to process data of interest
    strategy : string
        noise removal strategy used to process data of interest
    out_dir : string
        filepath to a local directory to save files to
    less_than : float
        upper age (years) threshold for participants of interest
    greater_than : float
        lower age (years) threshold for participants of interest
    site : string
        acquisition site of interest
    sex : string
        'M' or 'F' to indicate whether to download male or female data

    Returns
    -------
    None
        this function does not return a value; it downloads data from
        S3 to a local directory
    '''

    # Import packages
    import os
    import urllib

    # Init variables
    mean_fd_thresh = 0.2
    s3_prefix = 'https://s3.amazonaws.com/fcp-indi/data/Projects/'\
                'ABIDE_Initiative'
    s3_pheno_path = os.path.join(s3_prefix, 'Phenotypic_V1_0b_preprocessed1.csv')

    # Format input arguments to be lower case, if not already
    derivative = derivative.lower()
    pipeline = pipeline.lower()
    strategy = strategy.lower()

    # Check derivative for extension
    if 'roi' in derivative:
        extension = '.1D'
    else:
        extension = '.nii.gz'

    # If output path doesn't exist, create it
    if not os.path.exists(out_dir):
        print 'Could not find %s, creating now...' % out_dir
        os.makedirs(out_dir)

    # Load the phenotype file from S3
    s3_pheno_file = urllib.urlopen(s3_pheno_path)
    pheno_list = s3_pheno_file.readlines()

    # Get header indices
    header = pheno_list[0].split(',')
    try:
        site_idx = header.index('SITE_ID')
        file_idx = header.index('FILE_ID')
        age_idx = header.index('AGE_AT_SCAN')
        sex_idx = header.index('SEX')
        mean_fd_idx = header.index('func_mean_fd')
    except Exception as exc:
        err_msg = 'Unable to extract header information from the pheno file: %s'\
                '\nHeader should have pheno info: %s\nError: %s'\
                % (s3_pheno_path, str(header), exc)
        raise Exception(err_msg)

    # Go through pheno file and build download paths
    print 'Collecting images of interest...'
    s3_paths = []
    for pheno_row in pheno_list[1:]:

        # Comma separate the row
        cs_row = pheno_row.split(',')

        try:
            # See if it was preprocessed
            row_file_id = cs_row[file_idx]
            # Read in participant info
            row_site = cs_row[site_idx]
            row_age = float(cs_row[age_idx])
            row_sex = cs_row[sex_idx]
            row_mean_fd = float(cs_row[mean_fd_idx])
        except Exception as exc:
            err_msg = 'Error extracting info from phenotypic file, skipping...'
            print err_msg
            continue

        # If the filename isn't specified, skip
        if row_file_id == 'no_filename':
            continue
        # If mean fd is too large, skip
        if row_mean_fd >= mean_fd_thresh:
            continue

        # Test phenotypic criteria (three if's looks cleaner than one long if)
        # Test sex
        if (sex == 'M' and row_sex != '1') or (sex == 'F' and row_sex != '2'):
            continue
        # Test site
        if (site is not None and site.lower() != row_site.lower()):
            continue
        # Test age range
        if row_age < less_than and row_age > greater_than:
            filename = row_file_id + '_' + derivative + extension
            s3_path = os.path.join(s3_prefix, 'Outputs', pipeline, strategy,
                                   derivative, filename)
            print 'Adding %s to download queue...' % s3_path
            s3_paths.append(s3_path)
        else:
            continue

    # And download the items
    total_num_files = len(s3_paths)
    for path_idx, s3_path in enumerate(s3_paths):
        rel_path = s3_path.lstrip(s3_prefix)
        download_file = os.path.join(out_dir, rel_path)
        download_dir = os.path.dirname(download_file)
        if not os.path.exists(download_dir):
            os.makedirs(download_dir)
        try:
            if not os.path.exists(download_file):
                print 'Retrieving: %s' % download_file
                urllib.urlretrieve(s3_path, download_file)
                print '%.3f%% percent complete' % \
                      (100*(float(path_idx+1)/total_num_files))
            else:
                print 'File %s already exists, skipping...' % download_file
        except Exception as exc:
            print 'There was a problem downloading %s.\n'\
                  'Check input arguments and try again.' % s3_path

    # Print all done
    print 'Done!'


# Make module executable
if __name__ == '__main__':

    # Import packages
    import argparse
    import os
    import sys

    # Init arparser
    parser = argparse.ArgumentParser(description=__doc__)

    # Required arguments
    parser.add_argument('-d', '--derivative', nargs=1, required=True, type=str,
                        help='Derivative of interest (e.g. \'reho\')')
    parser.add_argument('-p', '--pipeline', nargs=1, required=True, type=str,
                        help='Pipeline used to preprocess the data '\
                             '(e.g. \'cpac\')')
    parser.add_argument('-s', '--strategy', nargs=1, required=True, type=str,
                        help='Noise-removal strategy used during preprocessing '\
                             '(e.g. \'nofilt_noglobal\'')
    parser.add_argument('-o', '--out_dir', nargs=1, required=True, type=str,
                        help='Path to local folder to download files to')

    # Optional arguments
    parser.add_argument('-lt', '--less_than', nargs=1, required=False,
                        type=float, help='Upper age threshold (in years) of '\
                                         'particpants to download (e.g. for '\
                                         'subjects 30 or younger, \'-lt 31\')')
    parser.add_argument('-gt', '--greater_than', nargs=1, required=False,
                        type=int, help='Lower age threshold (in years) of '\
                                       'particpants to download (e.g. for '\
                                       'subjects 31 or older, \'-gt 30\')')
    parser.add_argument('-t', '--site', nargs=1, required=False, type=str,
                        help='Site of interest to download from '\
                             '(e.g. \'Caltech\'')
    parser.add_argument('-x', '--sex', nargs=1, required=False, type=str,
                        help='Participant sex of interest to download only '\
                             '(e.g. \'M\' or \'F\')')

    # Parse and gather arguments
    args = parser.parse_args()

    # Init variables
    derivative = args.derivative[0].lower()
    pipeline = args.pipeline[0].lower()
    strategy = args.strategy[0].lower()
    out_dir = os.path.abspath(args.out_dir[0])

    # Try and init optional arguments
    try:
        less_than = args.less_than[0]
        print 'Using upper age threshold of %d...' % less_than
    except TypeError as exc:
        less_than = 200.0
        print 'No upper age threshold specified'
    try:
        greater_than = args.greater_than[0]
        print 'Using lower age threshold of %d...' % less_than
    except TypeError as exc:
        greater_than = -1.0
        print 'No lower age threshold specified'
    try:
        site = args.site[0]
    except TypeError as exc:
        site = None
        print 'No site specified, using all sites...'
    try:
        sex = args.sex[0].upper()
        if sex == 'M':
            print 'Downloading only male subjects...'
        elif sex == 'F':
            print 'Downloading only female subjects...'
        else:
            print 'Please specify \'M\' or \'F\' for sex and try again'
            sys.exit()
    except TypeError as exc:
        sex = None
        print 'No sex specified, using all sexes...'

    # Call the collect and download routine
    collect_and_download(derivative, pipeline, strategy,out_dir,
                         less_than, greater_than, site, sex)

