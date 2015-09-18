preprocessed-connectomes-project/abide
######################################

Contents
========
- download_abide_preproc.py - script to download ABIDE preprocessed data from S3, given phenotypic information
- map_rawout_to_organized_s3.py - script to organize the CPAC raw outputs from a pipeline run and organize them in the output format on S3

concordances
------------
- abide_cc_plots.R - R script to plot the pairwise concordance values from an ABIDE concordance data frame
- abide_concordances.pdf - The pair-wise concordance plots (cross-strategy, cross-pipeline) for ABIDE preprocessed
- big_df.csv.gz - G-zipped csv dataframe of all the pairwise concordances; unzipping this and passing it to abide_cc_plots.R will generate the abide_concordances.pdf
- pairwise_concordance.py - a script to compute the pairwise concordances of the ABIDE preprocessed outputs and save to dataframe as a csv file
- query_download_abide.py - script to manually download and check the pairwise concordance between two images based on a data frame entry (for verification of entries produced by pairwise_concorfance.py)

preprocessing
-------------

realigned_inputs
----------------
- Anonymized anatomical scans from sites that we had registration problems with (so we realigned them and used the realigned versions as inputs)

resources
---------
- abide_masks - nifti masked used in centrality calculation
- abide_rois - nifti roi files used in mean time series extraction
- abide_spatial_maps - nifti spatial maps file with 10 functional networks used for dual regression

scripts
-------
- eigen_run.py - script to run eigenvector centrality in isolation by downloading the functional preprocessed data from the raw CPAC output of a separate pipeline run
- eigen_run.sge - the sge bash submission script to run eigen_run.py over an HPC
- run_cpac.py - script to run CPAC on one subject (input is index of a subject list)
- run_cpac.sge - the sge bash submission script to run run_cpac.py over an HPC

settings
--------
- abide_rois.txt - text file with full paths to the ROI resources needed for timeseries extraction
- abide_spatial_maps.txt - text file with full paths to spatial maps used in dual regression
- centrality_mask.txt - text file with full paths to mask files used in centrality
- pipeline_config_abide_rerun.yml - CPAC configuration file for the CPAC ABIDE preprocessed outputs
- CPAC_subject_list_abide_rerun.yml - CPAC subject list for the CPAC ABIDE preprocessed inputs

yamls
-----
- ccs_missing.yml - CCS outputs that weren't produced
- comparisons_list.yml - list of pairwise comparisons
- map_dict_rerun - the mapping dictionary from raw output files to the S3-organized structure
- rerun2_subs.yml - subject ids that needed to have raw outputs regenerated twice
- subs_list.yml - full SITE_SUBID list of ABIDE subjects
