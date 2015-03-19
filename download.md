---
layout: page
title: Downloads
---

The results of the ABIDE Preprocessed initiative are available on a public Amazon S3 bucket and on NITRC. The data is available on the S3 bucket as a single file per derivative for each participant, pipeline and strategy, which provides flexibility about the files that are downloaded. The data on NITRC will be stored as a tarfile for each derivative, pipeline and strategy. 

### Accessing data from the Amazon S3 bucket
Each file in the S3 bucket is accessed using HTTP and is addressed by a corresponding URL. Because of this, data **cannot be accessed using ftp or scp**. Instead, a URL is constructed for each desired file (described below) and then this file can be downloaded using an HTTP client such as a web browser, `wget`, `curl`, or a custom script. Each file must be referred to by name, wildcards will not work. An example python script for downloading a subset of the data based on participant demographics is available [here](https://github.com/preprocessed-connectomes-project/abide/raw/master/get_s3_paths.py) (right click and select `Save Link As...`).

There are file transfer programs that can handle S3 natively and will allow you to navigate through the data using a file browser. [Cyberduck](https://cyberduck.io/) is one such program that works with Windows and Mac OS X as a GUI and there is a [command line version](https://duck.sh) that works with Windows, Mac OS X, and Linux. The following screenshot illustrates configuring Cyberduck to connect to the ABIDE Preprocessed data.

![Configuring Cyberduck to access ABIDE Preproced data](images/cyberduck_config.png "Configuring Cyberduck")

#### Meta-Data
A spreadsheet that contains phenotypic data and quality assessment information is available at: [https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Phenotypic_V1_0b_preprocessed1.csv](https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Phenotypic_V1_0b_preprocessed1.csv). Information from this file can be used to select a subset of the data that you would like to download. This file contains all of the information from the [original phenotypic file](http://www.nitrc.org/frs/downloadlink.php/4912) provided with the ABIDE release, which is described in the ABIDE [phenotypic data legend](http://fcon_1000.projects.nitrc.org/indi/abide/ABIDE_LEGEND_V1.02.pdf), except that information about the preprocessed data has been added. 

- The `FILE_ID` column provides a mapping between the phenotypic data and the preprocessed data filenames (see below). 
- Several columns of the spreadsheet contain quality measures from the [PCP Quality Assessment Protocol](http://preprocessed-connectomes-project.github.io/quality-assessment-protocol/) and are illustrated in detail on the [ABIDE Preprocessed quality assessment page](quality_assessment.html):

        anat_cnr, anat_efc, anat_fber, anat_fwhm, anat_qi1, anat_snr, func_efc, func_fber,
		func_fwhm, func_dvars, func_outlier, func_quality, func_mean_fd, func_num_fd, 
		func_perc_fd, func_gsr

- Also on this page are a description of the manual quality assessment annotations included in the columns: 
    
        qc_rater_1, qc_notes_rater_1, qc_anat_rater_2, qc_anat_notes_rater_2, qc_func_rater_2, 
        qc_func_notes_rater_2, qc_anat_rater_3, qc_anat_notes_rater_3, qc_func_rater_3, 
        qc_func_notes_rater_3 

- The `SUB_IN_SMP` column indicates whether the data was included in ([DiMartino et al. 2014](http://www.ncbi.nlm.nih.gov/pubmed/23774715)).
    
    
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

The file extension is determined by the derivative type. Use `nii.gz` for all derivatives except for the ROI time series files which end in `1D` (these derivative names begin with `rois_`). Refer to the [ROI description](Pipelines.html#regions_of_interest) for more information about the definition of the ROIs used to extract these time series and their labels.

Here are a few examples that illustrate the construction of paths for a few different files:

ALFF for 'OHSU\_0050147' preprocessed using 'filt\_global' from CPAC: [link](https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/filt_global/alff/OHSU_0050147_alff.nii.gz)<br>
    
    https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/filt_global/alff/OHSU_0050147_alff.nii.gz

Harvard-Oxford ROI time series for 'KKI\_0050822' preprocessed using 'filt\_global' from CPAC: [link](https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/filt_global/rois_ho/KKI_0050822_rois_ho.1D)<br>

    https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/filt_global/rois_ho/KKI_0050822_rois_ho.1D

The 3D binary derivatives (i.e. those ending in nii.gz except for 'func\_preproc' and 'dual\_reg') are roughly 256 KB to 512KB in size. The 'dual\_reg' files are 10 times the size of the others (i.e. 2.5MB - 5MB) and the 'func\_preproc' files are very large (30 MB - 200 MB). Extracted time series files are .5 - 1 MB in size.

##### Minimally preprocessed data

[Minimally preprocessed](Pipelines.html#min_preproc) data is available for the C-PAC pipeline. This data can be downloaded from the bucket using the url:

    https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/minimal/[file identifier]_minimal.nii.gz
	
For example, minimally preprocessed data for 'OHSU\_0050147' can be downloaded using: [link](https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/minimal/OHSU_0050147_minimal.nii.gz)<br>
    
    https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/minimal/OHSU_0050147_minimal.nii.gz
	

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
The entirity of the Freesurfer output folders for each subject are available for download using the following URL structure:

    https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/freesurfer/5.1/[file identifier]/[sub directory]/[output file]

where:

    [file identifier] comes from FILE_ID column of the summary spreadsheet
	[sub directory] is one of the standard Freesurfer subdirectories: label | mri | scripts | stats | surf 
    [output file] is the name of the desired output file

There are 284 files distributed across the subdirectories of each subject's output files. An example listing of the files for one subject is available [here](https://raw.githubusercontent.com/preprocessed-connectomes-project/abide/master/freesurfer_files.json) (right click and select `Save Link As ...`). The `-qcache` flag was used during reconstruction, so there are versions of the different surface metrics that have been smoothed at 0, 5, 10, 15, 20 and 25 mm FWHM. Information about the different subdirectories and files can be found in the [Freesurfer documentation](http://surfer.nmr.mgh.harvard.edu/fswiki/):

- [ReconAllOutputFiles](http://surfer.nmr.mgh.harvard.edu/fswiki/ReconAllOutputFiles)
- [ReconAllTableStableV5.1](http://surfer.nmr.mgh.harvard.edu/fswiki/ReconAllDevTable)
- [ReconAllFilesVsSteps](http://surfer.nmr.mgh.harvard.edu/fswiki/ReconAllFilesVsSteps)
- [Anatomical ROI analysis](http://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/AnatomicalROI)
- [Inspection of Freesurfer Output](http://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/OutputData_freeview)
- [FreeSurfer File Formats](http://surfer.nmr.mgh.harvard.edu/fswiki/FileFormats)

Freesurfer surfaces for each subject can be viewed online using the [ABIDE Preprocessed online viewer](OnlineViewer.html).

