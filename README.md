preprocessed-connectomes-project/abide
######################################

Contents
========
- get_s3_paths.py - script to find and download the S3 paths for the ABIDE outputs
- map_rawout_to_organized_s3.py - script to organize the CPAC raw outputs from a pipeline run and organize them in the output format on S3

concordances
------------
- abide_cc_plots.R - R script to plot the pairwise concordance values from an ABIDE concordance data frame
- pairwise_concordance.py - a script to compute the pairwise concordances of the ABIDE preprocessed outputs and save to dataframe as a csv file
- query_download_abide.py - script to manually download and check the pairwise concordance between two images based on a data frame entry (for verification of entries produced by pairwise_concorfance.py)

preprocessing
-------------

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
- rerun.yml - subject ids that needed to have raw outputs regenerated
- subs_list.yml - full SITE_SUBID list of ABIDE subjects
