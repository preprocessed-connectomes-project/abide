# Import packages
from CPAC.pipeline import cpac_pipeline
import sys

# Init variables
config = '/home/ubuntu/abide_run/settings/aws/pipeline_config_abide_rerun.yml'
subject_list = '/home/ubuntu/abide_run/settings/aws/CPAC_subject_list_abide_rerun.yml'
index = int(sys.argv[1])
strategies = '/home/ubuntu/abide_run/resources/strategies.obj'
mask_spec = None
roi_spec = '/home/ubuntu/abide_run/settings/aws/rois.txt'
tmp_spec = '/home/ubuntu/abide_run/settings/aws/centrality_mask.txt'
p_name = 'abide_rerun'
creds_path = '/home/ubuntu/secure_creds/aws-keys/fcp-indi-keys2.csv'
bucket_name = 'fcp-indi'
bucket_prefix = 'data/Projects/ABIDE_Initiative/RawData'
bucket_upload_prefix = 'data/Projects/ABIDE_Initiative/Outputs/cpac/raw_outputs_rerun'
local_prefix = '/mnt/inputs'

cpac_pipeline.run(config, subject_list, index, strategies,
                  mask_spec, roi_spec, tmp_spec, p_name=p_name,
                  creds_path=creds_path, bucket_name=bucket_name,
                  bucket_prefix=bucket_prefix, bucket_upload_prefix=bucket_upload_prefix,
                  local_prefix=local_prefix)
