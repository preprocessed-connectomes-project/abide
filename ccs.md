---
layout: page
title: ccs
---

# Brief introduction of CCS processing procedure

Three main analysis software packages, AFNI, FSL and Freesurfer, were integrated into CCS pipeline computation as follow.

## Structural image preprocessing
1. MR denoised by a spatially adaptive non-local means filter (Xing et al., 2011; Zuo and Xing, 2011) using the extensions utility of VBM toolboxes of SPM8.
2. Skull stripped with FREESURFER step (-autorecon1), integrating with BET tool in FSL. Specifically, two fractional intensity thresholds, loose and tight, were used to extract brain in FSL. Subsequently, three brain masks, one from FREESURFER, two from BET were manually screened for users to choose the best one for the next surface reconstruction step. Occasionally, the bad skull strip were manual fixed in this step.
3. Surface reconstructed in FREESURFER (-autorecon2 and –autorecon3).
4. Normalized individual skull stripped brain according to MNI152 standard template (MNI152_T1_2mm_brain) with linear affine and followed by the nonlinear warp with FLIRT and FNIRT in FSL. 

## Functional image preprocessing
1. Functional preprocessing included dropping the first 4 volumes of functional images, removing the spikes (3dDespike), slice timing (3dTshift), and motion correction (3dvolreg).
2. Created a brain mask for functional images through a series steps, which include register the anatomical brain mask to functional image (FLIRT), get rid of the voxels without any detectable signals, and combine with 3dAutomask in AFNI, the intersection mask is used for the final functional brain mask for extracting the global signal of the brain.
3. 4D global mean-based intensity normalization.
4. Boundary-based registration (BBR) from functional image to individual anatomical image in FREESURFER with FSL initial matrix.
5. In order to extract the grey matter (GM), white matter (WM), and cerebrospinal fluid (CSF) for functional images, the anatomical segmentation of GM, WM, and CSF was applied on functional images by mri_vol2vol command with bbregister affine matrix. 
6. Nuisance correction was conducted by regression out the Friston’s 24-parameter motion signal, the mean time series or the principal component based on singular value decomposition from WM and CSF, then the linear and quadratic trends. The regression included and excluded global signal are both saved for the post process.
7. Band-pass temporal filtering (0.01-0.1Hz) was performed for extracting the low frequency fluctuations with 3dFourier command in AFNI.
8. Registered the individual functional images to MNI template with affine matrix from bbregister and warp file from FNIRT step.

