---
layout: page
title: pipelines
---

# Analysis

All the structural and functional scans were preprocessed with four different pipelines with the goal of comparing the outputs and determining best practices. Each pipeline used the best tools available to each of them and employed methods commonly used in the literature. We used the functional preprocessed data output from each pipeline to then calculate derivatives using CPAC. For a comparison of the derivative outputs between the pipelines, please [see this page](http://preprocessed-connectomes-project.github.io/abide/derivatives.html).


## Pipelines

Below are the list of different pipelines with links to more detailed descriptions.

* [Connectome Computation System (CCS)](http://preprocessed-connectomes-project.github.io/abide/ccs.html): bash
* [Configurable Pipeline for the Analysis of Connectomes (CPAC)](http://preprocessed-connectomes-project.github.io/abide/cpac.html): python
* [Data Processing Assistant for Resting-State fMRI (DPARSF)](http://preprocessed-connectomes-project.github.io/abide/dparsf.html): matlab
* [Neuroimaging Analysis Kit (NIAK)](http://preprocessed-connectomes-project.github.io/abide/niak.html): matlab

Here we provide an overview of each pipeline with comparisons of critical steps.

## Functional Data

### Outputs

The final outputs for each pipeline were preprocessed functional time-series data in native and standard (MNI152) space. Due to controversies in the literature, these outputs could be with/without band-pass filtered (0.01-0.1 Hz) and with/without global signal regression. Thus, for each pipeline, four different types of preprocessed outputs or strategies were produced. These include:

| | Band-Pass Filtering | Global Signal Regression |
| - | - | - |
| 1 | Yes | Yes |
| 2 | Yes | No  |
| 3 | No  | Yes |
| 4 | No  | No  |

### Functional Preprocessing

Below we show select steps during functional preprocessing and compare them between the pipelines.

| Step |   CCS  |  CPAC  | DPARSF |  NIAK  |
| ----: | :------: | :------: | :------: | :------: |
| drop first volumes | 4 volumes | none | 4 volumes | none |
| slice time correction | yes | yes | yes | no |
| motion correction | yes | yes | yes | yes |
| intesity normalization | 4D global mean-based | 4D global mean-based | no | Non-uniformity correction based on median volume |

Band-pass filtering was also applied or not applied at the end of these steps. Smoothing to the functional data was also applied using 6mm FWHM kernal.

### Nuisance Signal Removal

Attempts to remove noise in the functional data were taken using linear regression for each pipeline.

| Type of Regressor |   CCS  |  CPAC  | DPARSF |  NIAK  |
| -----------------: | ------ | ------ | ------ | ------ |
| Motion            | 24-parameters | 24-parameters | 24-parameters | scrubbing and 1st principal component of 6-parameters & their squares |
| Cardiac/Respiratory | mean signal from WM and CSF | top 5 principal components from WM and CSF | mean signal from WM and CSF | mean signal from WM and CSF |
| Low-frequency drifts | linear and quadratic trends | linear and quadratic trends | linear and quadratic trends | basis of discrete cosines with a 0.01 Hz high-pass cut-off |

The 24-parameters are from Friston's model[^1] using 6 head motion parameters, 6 head motion parameters one time point before, and the 12 corresponding squared items.

### Registration

| Step |   CCS  |  CPAC  | DPARSF |  NIAK  |
| ----: | :------: | :------: | :------: | :------: |
| functional to anatomical | boundary-based rigid-body | boundary-based  rigid body | rigid-body | rigid-body |
| anatomical to standard | FLIRT + FNIRT | FLIRT + ANTS | SPM + DARTEL | CIVET[^2] |


Functional data for each pipeline was transformed using the combination of the functional to anatomical and anatomical to standard steps. This transformation was applied only when functional preprocessing was complete. For the VMHC derivative, we also calculated a transformation to the symmetric standard brain for each pipeline.

### Surface

We note that the CCS pipeline also produced outputs of anatomical and functional data in surface space using Freesurfer. This was in addition to the volume-based analysis described for CCS above.


## Derivatives

Several derivatives (e.g., regional homogeneity) were generated using the functional preprocessed output. Since there were four different functional outputs related to bandpass filtering and/or global signal regression, each derivative has four different outputs. As mentioned earlier, these derivatives were all generated using CPAC. Although the calculation of the derivatives were the same for every pipeline, there were differences in each pipeline as to when each derivative was registered to standard space and when smoothing was applied.

### Approach 1

For CCS, CPAC, and DPARSF, we calculated the derivatives listed below in native space using unsmoothed functional data and then apply prior transformation to standard space followed by smoothing with a 6mm FWHM kernal. The registration and smoothing were done using steps specific to each pipeline.

* Amplitude of low frequnecy fluctuations (ALFF)
* Fractional ALFF (fALFF)
* Regional homogeniety (REHO)
* 10 intrinsic connectivity networks extracted using dual regression

In contrast, the derivatives listed below were calculated on the unsmoothed functional data already in standard space and then 6mm of smoothing was applied to the results.

* Weighted and binarized degeree centrality
* Weighted and binarized eigenvector centrality
* Local functional connectivity density (lFCD)
* Voxel-mirrored homotopic connectivity (VMHC)

Note as mentioned earlier the VMHC was calculated on the functional data registered to the symmetric standard MNI152 brain. 


### Approach 2

In the NIAK pipeline, derivatives were always calculated on data that was already registered to standard space and smoothed with 6mm FWHM.

### Regions of Interest

We also extracted mean time-series for several sets of regions-of-interests. In each case, the mean time-series was taken from functional data already registered in standard space for every pipeline. More specifically, time series were extracted for seven ROI atlases:

* Automated Anatomical Labelling
* Eickhoff-Zilles
* Harvard-Oxford
* Talaraich and Tournoux
* Dosenbach 160
* Craddock 200
* Craddock 400


## References

[^1]: Friston, K.J., Williams, S., Howard, R., Frackowiak, R.S., Turner, R., 1996. Movement-related effects in fMRI time-series. Magn Reson Med 35, 346-355.
[^2]: Zijdenbos, A. P., Forghani, R., & Evans, A. C. (2002). Automatic" pipeline" analysis of 3-D MRI data for clinical trials: application to multiple sclerosis. Medical Imaging, IEEE Transactions on, 21(10), 1280-1291.
(Behzadi et al., 2007; Chai et al., 2012)