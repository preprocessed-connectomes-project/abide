---
layout: page
title: Downloads
---

The results of the ABIDE Preprocessed initiative are available on a public Amazon S3 bucket and on NITRC. The data is available on the S3 bucket as a single file per derivative for each participant, pipeline and strategy, which provides flexibility about the files that are downloaded. The data on NITRC will be stored as a tarfile for each derivative, pipeline and strategy. 

### Accessing data from the Amazon S3 bucket
Each file in the S3 bucket is accessed using HTTP and is addressed by a corresponding URL. Because of this, data **cannot be accessed using a ftp or scp client**. Instead, a URL is constructed for each desired file, and then this file can be downloaded using an HTTP client such as a web browser, `wget`, `curl`, or a custom script. Each file must be referred to by name, wildcards will not work. An example python script for downloading a subset of the data based on participant demographics is available [here](path_to_dl_script).

The structure of the data on the S3 bucket can be browsed by opening the bucket root  ([https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative](https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative)) in a web browser.


#### Meta-Data
A spreadsheet that contains phenotypic data and quality assessment information is available at: [https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Phenotypic_V1_0b_preprocessed1.csv](https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Phenotypic_V1_0b_preprocessed1.csv). Information from this file can be used to select a subset of the data that you would like to download. This file contains all of the information from the [original phenotypic file](http://www.nitrc.org/frs/downloadlink.php/4912) provided with the ABIDE release, which is described in the ABIDE [phenotypic data legend](http://fcon_1000.projects.nitrc.org/indi/abide/ABIDE_LEGEND_V1.02.pdf), except that information about the preprocessed data has been added. 

A column has been added to assist with mapping the information to the preprocessed data (see below):

    FILE_ID

Several columns contain quality measures from the [PCP Quality Assessment Protocol](http://preprocessed-connectomes-project.github.io/quality-assessment-protocol/) and are illustrated in detail on the [ABIDE Preprocessed quality assessment page](quality_assessment.html):

    anat_cnr, anat_efc, anat_fber, anat_fwhm, anat_qi1, anat_snr, func_efc, func_fber, func_fwhm, 
    func_dvars, func_outlier, func_quality, func_mean_fd, func_num_fd, func_perc_fd, func_gsr

Also on this page are a description of the manual quality assessment annotations included in the columns: 
    
    qc_rater_1, qc_notes_rater_1, qc_anat_rater_2, qc_anat_notes_rater_2, qc_func_rater_2, 
    qc_func_notes_rater_2, qc_anat_rater_3, qc_anat_notes_rater_3, qc_func_rater_3, 
    qc_func_notes_rater_3 

The remaining additional column indicates whether the data was included in ([DiMartino et al. 2014](http://www.ncbi.nlm.nih.gov/pubmed/23774715)):
    
    SUB_IN_SMP

#### Functional Data
Preprocessed functional data can be downloaded from the bucket using the url:

    https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/

appedend with the string: 

    [pipeline]/[strategy]/[derivative]/[file identifier]_[derivative].[ext]

Where:<br> 

    [pipeline] = ccs | cpac | dparsf | niak 
    [stratgey] = filt_global | filt_noglobal | nofilt_global | nofilt_noglobal
    [file identifier] comes from FILE_ID column of the summary spreadsheet
    [derivative] = alff | degree_binarize | degree_weighted | dual_regression | ... 
                   eigenvector_binarize | eigenvector_weighted | falff | func_mask | ... 
                   func_mean | func_preproc | lfcd | reho | rois_aal | rois_cc200 | ... 
                   rois_cc400 | rois_dosenbach160 | rois_ez | rois_ho | rois_tt | vmhc
    [ezt] = 1D | nii.gz

The file extension is determined by the derivative type. Use `nii.gz` for all derivatives except for the ROI time series files which end in `1D` (these derivative names begin with `rois_`).

Here are a few examples that illustrate the construction of paths for a few different files:

ALFF for 'OHSU\_0050147' preprocessed using 'filt\_global' from CPAC: [link](https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/filt_global/alff/OHSU_0050147_alff.nii.gz)<br>
    
    https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/filt_global/alff/OHSU_0050147_alff.nii.gz

Harvard-Oxford ROI time series for 'KKI\_0050822' preprocessed using 'filt\_global' from CPAC: [link](https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/filt_global/rois_ho/KKI_0050822_rois_ho.1D)<br>

    https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/filt_global/rois_ho/KKI_0050822_rois_ho.1D

The 3D binary derivatives (i.e. those ending in nii.gz except for 'func\_preproc' and 'dual\_reg') are roughly 256 KB to 512KB in size. The 'dual\_reg' files are 10 times the size of the others (i.e. 2.5MB - 5MB) and the 'func\_preproc' files are very large (30 MB - 200 MB). Extracted time series files are .5 - 1 MB in size.


#### Structural Data
Due to the diversity of the structural pipelines, each pipeline has a different format for specifying its derivatives. The aforementioned [python script](link_to_python_script) also provides examples for downloading this data. Again, file identifiers correspond to values from the [ABIDE Preprocessed phenotype file](https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Phenotypic_V1_0b_preprocessed1.csv).

##### ANTS Cortical Thickness
Cortical thickness measures calculated using the ANTs pipeline can be downloaded using the root url:         
        
    https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/ants/

appended with a string corresponding to one of the two available cortical thickness derivatives:

1. A 3D volume containing voxel-wise measures of cortical thickness:

        anat_thickness/[file identifier]_anat_thickness.nii.gz   

2. A text file containing average cortical thickness values for cortical regions of interests (ROIs):

        roi_thickness/[file identifier]_roi_thickness.txt

##### CIVET

##### FreeSurfer
Outputs from the FreeSurfer can be accessed using the root URL:

    https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/freesurfer/
    
appended with a string corresponding to the derived measure for a particular participant.

Files containing ROI based statistics can be accessed by appending the root URL with a string of the form:

    [derivative]/[file identifier]_[derivatve].stats
    
Where:

    derivative = stats_aseg | stats_lh_BA | stats_lh_aparc | stats_lh_aparc_a2009a | ... 
                 stats_lh_entorhinal_exvivo | stats_rh_BA | stats_rh_aparc | ... 
                 stats_rh_aparc_a2009a | stats_rh_entorhinal_exvivo | stats_wmparc 

Files containing vertex-wise statistics can be accessed appending the root URL with a string of the form:
    
    surf_[hemisphere]_[measure]/[file identifier]_surf_[hemisphere].[measure]
    
Where:

    hemisphere = lh | rh
    measure = area | curv | sulc | thickness | volume
    
###### For example:

Statistics for left hemisphere ROIs defined by the Destrieux Atlas for `file identifier = CMU_a_0050642` can be downloaded using this [link](https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/freesurfer/stats_lh_aparc_a2009s/CMU_a_0050642_stats_lh.aparc.a2009s.stats):

    https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/freesurfer/stats_lh_aparc_a2009s/CMU_a_0050642_stats_lh.aparc.a2009s.stats

