---
layout: page
title: cpac
---

# Preprocessing with CPAC

Preprocessing of the ABIDE data was done with version X of the Conﬁgurable Pipeline for the Analysis of Connectomes
(C-PAC, http://fcp-indi.github.com). This python-based pipeline tool makes use of AFNI, ANTs, FSL, and custom python code.

## Structual Preprocessing

1. Skull-stripping using AFNI's _3dSkullStrip_
2. Segment the brain into three tissue types using FSL's _FAST_
3. Constrain the individual subject tissue segmentations by tissue priors from standard space provided with FSL
4. Individual skull stripped brains were normalized to Montreal Neurological Institute (MNI)152 stereotactic space (1 mm^3 isotropic) with linear and non-linear registrations using ANTs.

## Functional Preprocessing

1. Slice time correction using AFNI's _3dTshift_
2. Motion correct to the average image using AFNI's _3dvolreg_ (two iterations)
3. Skull-strip using AFNI's _3dAutomask_
4. Global mean intensity normalization to 10,000
5. Nuisance signal regression was applied including
	* motion parameters: 6 head motion parameters, 6 head motion parameters one time point before, and the 12 corresponding squared items
	* top 5 principal components from the signal in the white-matter and cerebro-spinal fluid derived from the prior tissue segmentations transformed from anatomical to functional space
	* linear and quadratic trends
	* global signal only for one set of strategies
6. Band-pass filtering (0.01-0.1Hz) was applied for only for one set of strategies
7. Functional images were registered to anatomical space with a linear transformation and then a white-matter boundary based transformation using FSL's _FLIRT_ and the prior white-matter tissue segmentation from _FAST_
8. The previous anatomical to standard space registration was applied to the functional data in order to transform them to standard space

