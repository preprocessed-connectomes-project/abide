---
layout: page
title: pipelines
---

# Functional Preprocessing

There is no concensus on the best methods for preprocessing resting state fMRI data. Rather than being perscriptive and favoring a single processing strategy, we have preprocessed the data using four different preprocessing pipelines, each of which was implemented using the chosen parameters and settings of the pipeline developers.

* [Connectome Computation System (CCS)](http://preprocessed-connectomes-project.github.io/abide/ccs.html)
* [Configurable Pipeline for the Analysis of Connectomes (CPAC)](http://preprocessed-connectomes-project.github.io/abide/cpac.html)
* [Data Processing Assistant for Resting-State fMRI (DPARSF)](http://preprocessed-connectomes-project.github.io/abide/dparsf.html)
* [Neuroimaging Analysis Kit (NIAK)](http://preprocessed-connectomes-project.github.io/abide/niak.html)

The preprocessing steps implemented by the different pipelines are fairly similar. What varies most are the specific algorithms used for each of the steps, their software implementations, and the parameters used. The following sections provide an overview of the different preprocessing steps and how they vary across pipelines.

### Basic Processing

<center>
<table id="pubTable" class="display2">
<thead>
	<tr>
		<th>Step</th>
		<th>CCS</th>
		<th>C-PAC</th>
		<th>DPARSF</th>
		<th>NIAK</th>
	</tr>
</thead>
<tbody>
	<tr class="odd">
		<td class="nowrap">Drop first "N" volumes</td>
		<td>4</td>
		<td>0</td>
		<td>4</td>
		<td>0</td>
	</tr>
	<tr class="even">
		<td class="nowrap">Slice timing correction</td>
		<td>Yes</td>
		<td>Yes</td>
		<td>Yes</td>
		<td>No</td>
	</tr>
	<tr class="odd">
		<td class="nowrap">Motion realignment</td>
		<td>Yes</td>
		<td>Yes</td>
		<td>Yes</td>
		<td>Yes</td>
	</tr>
	<tr class="even">
		<td class="nowrap">Intensity normalization</td>
		<td>4D Global mean = 1000</td>
		<td>4D Global mean = 1000</td>
		<td>No</td>
		<td>Non-uniformity correction<br>using median volume</td>
	</tr>
</tbody>
</table>
</center>

### Nuisance Signal Removal

Each pipeline implemented some form of nuisance variable regression[^3]<sup>,</sup>[^4] to clean confounding variation due to physiological processes (heart beat and respiration), head motion, and low frequency scanner drifts, from the fMRI signal.

<center>
<table id="pubTable" class="display2">
<thead>
	<tr>
		<th>Regressor</th>
		<th>CCS</th>
		<th>C-PAC</th>
		<th>DPARSF</th>
		<th>NIAK</th>
	</tr>
</thead>
<tbody>
	<tr class="odd">
		<td class="nowrap">Motion</td>
		<td>24-param</td>
		<td>24-param</td>
		<td>24-param</td>
		<td>scrubbing and 1st principal component of 6 motion parameters & their squares</td>
	</tr>
	<tr class="even">
		<td class="nowrap">Tissue signals</td>
		<td>mean WM and CSF signals</td>
		<td>CompCor<br>(5 PCs)</td>
		<td>mean WM and CSF signals</td>
		<td>mean WM and CSF signals</td>
	</tr>
	<tr class="odd">
		<td class="nowrap">Motion realignment</td>
		<td>Yes</td>
		<td>Yes</td>
		<td>Yes</td>
		<td>Yes</td>
	</tr>
	<tr class="even">
		<td class="nowrap">Low-frequency drifts</td>
		<td>linear and quadratic trends</td>
		<td>linear and quadratic trends</td>
		<td>linear and quadratic trends</td>
		<td>discrete cosine basis with a 0.01 Hz high-pass cut-off</td>
	</tr>
</tbody>
</table>
</center>

### Processing strategies

Each pipeline was used to calculate four different preprocessing strategies:

<center>
<table id="pubTable" class="display2">
<thead>
	<tr>
		<th>Strategy</th>
		<th>Band-Pass Filtering</th>
		<th>Global Signal Regression</th>
	</tr>
</thead>
<tbody>
	<tr class="odd">
		<td>filt_global</td>
		<td>Yes</td>
		<td>Yes</td>
	</tr>
	<tr class="even">
		<td>filt_noglobal</td>
		<td>Yes</td>
		<td>No</td>
	</tr>
	<tr class="odd">
		<td>nofilt_global</td>
		<td>No</td>
		<td>Yes</td>
	</tr>
	<tr class="even">
		<td>nofilt_noglobal</td>
		<td>No</td>
		<td>No</td>
	</tr>
</tbody>
</table>
</center>

For strategies that include global signal correction, the global mean signal was included with nuisance variable regression. Band-pass filtering (0.01 - 0.1 Hz) was applied after nuisance variable regression.

### Registration

A transform from original to template (MNI152) space was calculated for each dataset from a combination of functional-to-anatomical and anatomical-to-template transforms. The anatomical-to-template transforms were calculated using a two step procedure that involves (one or more) linear transform that is later refined with a very high dimensional non-linear transform. When data are written into template space (typically after the calculation of derivatives, except for NIAK) all transforms are used simultaneously to avoid multiple interpolations.

<center>
<table id="pubTable" class="display2">
<thead>
	<tr>
		<th>Registration</th>
		<th>CCS</th>
		<th>C-PAC</th>
		<th>DPARSF</th>
		<th>NIAK</th>
	</tr>
</thead>
<tbody>
	<tr class="odd">
		<td class="nowrap">Functional to Anatomical</td>
		<td>boundary-based rigid body (BBR)</td>
		<td>boundary-based rigid body (BBR)</td>
		<td class="nowrap">rigid body</td>
		<td class="nowrap">rigid body</td>
	</tr>
	<tr class="even">
		<td class="nowrap">Anatomical to Standard </td>
		<td>FLIRT + FNIRT</td>
		<td>ANTs</td>
		<td>DARTEL </td>
		<td>CIVET</td>
	</tr>
</tbody>
</table>
</center>

## Derivatives

Statistical derivatives (e.g., regional homogeneity) were generated from preprocessed functional data for each of the four processing strategies generated from each of the four processing pipelines. As mentioned earlier, these derivatives were all generated using CPAC. Although the calculation of the derivatives were the same for every pipeline, there were differences in each pipeline as to when each derivative was registered to standard space and when smoothing was applied. In every case the final resolution of the calculated derivatives is 3x3x3 mm<sup>3</sup>.

### Approach 1

For CCS, CPAC, and DPARSF, the derivatives listed below were calculated in native space using unsmooted functional data. The results were then written into template space (MNI152) and spatially smoothed with a 6-mm FWHM Gaussian kernel. The registration and smoothing were performed using steps specific to each pipeline.

* [Amplitude of low frequency fluctuations (ALFF) and Fractional ALFF (fALFF)](http://fcp-indi.github.io/docs/user/alff.html)
* [Regional homogeneity (REHO)](http://fcp-indi.github.io/docs/user/reho.html)
* [10 Intrinsic Connectivity Networks](http://www.fmrib.ox.ac.uk/analysis/brainmap+rsns/)[^6] extracted using [Dual Regression](http://fcp-indi.github.io/docs/user/dual_reg.html)

In contrast, the derivatives listed below were calculated on the unsmoothed functional data in template (MNI152) space and then smoothed with a 6-mm FWHM Gaussian kernel.

* [Weighted and binarized degree centrality](http://fcp-indi.github.io/docs/user/centrality.html)
* [Weighted and binarized eigenvector centrality](http://fcp-indi.github.io/docs/user/centrality.html)
* [Local functional connectivity density (lFCD)](http://fcp-indi.github.io/docs/user/centrality.html)
* [Voxel-mirrored homotopic connectivity (VMHC)](http://fcp-indi.github.io/docs/user/vmhc.html)

Note as mentioned earlier VMHC was calculated on the functional data registered to the symmetric standard MNI152 brain. 

### Approach 2

In the NIAK pipeline, the functional data was written into template space and spatially smoothed with a 6-mm FWHM Gaussian kernel prior to calculating the statistical derivatives.

### <a name="regions_of_interest">Regions of Interest</a>

We also extracted mean time-series for several sets of regions-of-interests. In each case, the mean time-series was taken from functional data already registered in standard space for every pipeline. More specifically, time series were extracted for seven ROI atlases:

* **Automated Anatomical Labeling (AAL):** The AAL atlas distributed with the [AAL Toolbox](http://www.cyceron.fr/web/aal__anatomical_automatic_labeling.html) was fractionated to functional resolution (3x3x3 mm<sup>3</sup>) using nearest-neighbor interpolation. [[Atlas](https://fcp-indi.s3.amazonaws.com/data/Projects/ABIDE_Initiative/Resources/aal_roi_atlas.nii.gz)] [[Labels](https://fcp-indi.s3.amazonaws.com/data/Projects/ABIDE_Initiative/Resources/aal_roi_atlas.nii.gz)]

* **Eickhoff-Zilles (EZ):** The EZ atlas was derived from the max-propagation atlas distributed with the [SPM Anatomy Toolbox](http://www.fz-juelich.de/inm/inm-1/spm_anatomy_toolbox). The atlas was transformed into template space using the Colin 27 template (also distributed with the toolbox) as an intermediary and fractionated into functional resolution using nearest-neighbor interpolation. [[Atlas](https://fcp-indi.s3.amazonaws.com/data/Projects/ABIDE_Initiative/Resources/ez_roi_atlas.nii.gz)][[Labels](https://fcp-indi.s3.amazonaws.com/data/Projects/ABIDE_Initiative/Resources/ez_roi_atlas.nii.gz)]

* **Harvard-Oxford (HO):** The HO atlas distributed with [FSL](http://www.fmrib.ox.ac.uk/fsl/) is split into cortical and subcortical probabilistic atlases. A 25% threshold was applied to each of these atlases and they were subsequently bisected into left and right hemispheres at the midline (x=0). ROIs representing left/right WM, left/right GM, left/right CSF and brainstem were removed from the subcortical atlas. The subcortical and cortical ROIs were combined and then fractionated into functional resolution using nearest-neighbor interpolation. [[Atlas](https://fcp-indi.s3.amazonaws.com/data/Projects/ABIDE_Initiative/Resources/ho_roi_atlas.nii.gz)][[Labels](https://fcp-indi.s3.amazonaws.com/data/Projects/ABIDE_Initiative/Resources/ho_roi_atlas.nii.gz)]

* **Talaraich and Tournoux (TT):** The TT atlas distributed with [AFNI](http://afni.nimh.nih.gov/afni/) was coregistered and warped into template space and subsequently fractionated into functional resolution using nearest neighbor interpolation. [[Atlas](https://fcp-indi.s3.amazonaws.com/data/Projects/ABIDE_Initiative/Resources/tt_roi_atlas.nii.gz)][[Labels](https://fcp-indi.s3.amazonaws.com/data/Projects/ABIDE_Initiative/Resources/tt_roi_atlas.nii.gz)]

* **Dosenbach 160:** The Dosenbach 160 atlas distributed with [DPARSF/DPABI](http://rfmri.org/dparsf) includes 160 4.5-mm radius spheres placed at coordinates from Table S6 in Dosenbach et al., 2010[^8]. These regions were identified from meta-analyses of task-related fMRI studies. [[Atlas](https://fcp-indi.s3.amazonaws.com/data/Projects/ABIDE_Initiative/Resources/dos160_roi_atlas.nii.gz)][[Labels](https://fcp-indi.s3.amazonaws.com/data/Projects/ABIDE_Initiative/Resources/dos160_roi_atlas.nii.gz)]

* **Craddock 200 (CC200):** Functional parcellation was accomplished using a two-stage spatially-constrained functional procedure applied to preprocessed and unfiltered resting state data corresponding to 41 individuals from an independent dataset (age: 18–55; mean 31.2; std. dev. 7.8; 19 females)[^7]. A grey matter mask was constructed by averaging individual-level grey matter masks derived by automated segmentation. Individual-level connectivity graphs were constructed by treating each within-gm-mask voxel as a node and edges corresponding to super-threshold temporal correlations to the voxels' 3D (27 voxel) neighborhood. Each graph was partitioned into 200 regions using normalized cut spectral clustering. Association matrices were constructed from the clustering results by setting the connectivity between voxels to 1 if they are in the same ROI and 0 otherwise. A group-level correspondence matrix was constructed by averaging the individual level association matrices and subsequently partitioned into 200 regions using normalized cut clustering. The resulting group-level analysis was fractionated into functional resolution using nearest-neighbor interpolation. Labels were generated for each of the resulting ROIs from their overlap with AAL, EZ, HO, and TT atlases using the cluster naming script distributed with the [pyClusterROI toolbox](http://ccraddock.github.io/cluster_roi/atlases.html). [[Atlas](https://fcp-indi.s3.amazonaws.com/data/Projects/ABIDE_Initiative/Resources/cc200_roi_atlas.nii.gz)][[Labels](https://fcp-indi.s3.amazonaws.com/data/Projects/ABIDE_Initiative/Resources/CC200_ROI_labels.csv)]

* **Craddock 400 (CC200):** The procedure described for the CC200 atlas was repeated for 400 regions to create the CC400 atlas. [[Atlas](https://fcp-indi.s3.amazonaws.com/data/Projects/ABIDE_Initiative/Resources/cc400_roi_atlas.nii.gz)][[Labels](https://fcp-indi.s3.amazonaws.com/data/Projects/ABIDE_Initiative/Resources/CC400_ROI_labels.csv)]

### <a name="min_preproc">Minimally Preprocessed Data</a>

Minimally preprocessed data is only available for the C-PAC pipeline and was processed using only the following steps:

1. Slice timing correction
2. Realignment to correct for motion
3. Written into template space at 3x3x3 mm<sup>3</sup> isotropic resolution

# References

[^1]: Friston, K.J., Williams, S., Howard, R., Frackowiak, R.S., Turner, R., 1996. Movement-related effects in fMRI time-series. Magn Reson Med 35, 346-355.
[^2]: Zijdenbos, A. P., Forghani, R., & Evans, A. C. (2002). Automatic" pipeline" analysis of 3-D MRI data for clinical trials: application to multiple sclerosis. Medical Imaging, IEEE Transactions on, 21(10), 1280-1291.
[^3]: Lund
[^4]: Fox 2005
[^5]: Behzadi et al., 2007
[^6]: Chai et al., 2012
[^7]:Craddock, R. C., James, G. A., Holtzheimer, P. E., Hu, X. P., & Mayberg, H. S. A whole brain fMRI atlas generated via spatially constrained spectral clustering, Human Brain Mapping, 2012, 33, 1914-1928 doi: 10.1002/hbm.21333.
[^8]: Dosenbach, Nico U. F. et al. “Prediction of Individual Brain Maturity Using fMRI.” Science (New York, N.Y.) 329.5997 (2010): 1358–1361. PMC. Web. 21 Mar. 2015. doi: 10.1126/science
