### get_s3_paths.py
#
# Written by Daniel Clark, Child Mind Institute, 2014
#
# Script for downloading ABIDE preprocessed data from AWS S3 bucket.
# This requires that the phenotypic data file that is located at:
#    https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Phenotypic_V1_0b_preprocessed1.csv
# be copied locally.

# Import packages
import csv
import os
import pandas
import urllib

# Path to phenotypic csv file
csv_path = '/local/path/to/Phenotypic_V1_0b_preprocessed.csv'
# Download directory
download_root = '/local/path/to/download/base/directory/'
# S3 path prefix
s3_prefix = 'https://s3.amazonaws.com/fcp-indi/data/Projects/'\
            'ABIDE_Initiative/Outputs/'

# --- Download from the S3 bucket based on phenotypic conditions ---
# Read in phenotypic file csv
sub_pheno_list = []
csv_in = pandas.read_csv(csv_path)
r = 0
# Iterate through the csv rows (subjects)
for row in csv_in.iterrows():
    site = csv_in['SITE_ID'][r]
    sub_id = csv_in['SUB_ID'][r]
    file_id = csv_in['FILE_ID'][r]
    sex = csv_in['SEX'][r]
    age = csv_in['AGE_AT_SCAN'][r]
    # Test phenotypic conditions
    if (site == 'CALTECH' and sex == 1 and age > 30):
        sub_pheno_list.append(file_id)
    r += 1

# Strip out 'no_filename's from list
sub_pheno_list = [s for s in sub_pheno_list if s != 'no_filename']

# Choose pipeline, strategy, and derivative of interest
pipeline = 'cpac'
strategy = 'filt_global'
derivative = 'degree_binarize'

# Fetch s3 path for each file_id that met the phenotypic conditions
path_list = []
for file_id in sub_pheno_list:
    file_path = pipeline + '/' + strategy + '/' + derivative + \
              '/' + file_id + '_' + derivative + '.nii.gz'
    path_list.append(file_path)

# Print list of paths one can wget to download
#print path_list

# And download the items
for path in path_list:
    download_file = os.path.join(download_root, path)
    download_dir = os.path.dirname(download_file)
    if not os.path.exists(download_dir):
        os.makedirs(download_dir)
    if not os.path.exists(download_file):
        print('Retrieving: ' + download_file)
        urllib.urlretrieve(s3_prefix + path, download_file)

