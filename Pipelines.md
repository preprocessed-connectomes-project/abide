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


### Functional Preprocessing

Below we show select steps during functional preprocessing and compare them between the pipelines.
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

Statistical derivatives (e.g., regional homogeniety) were generated from preprocessed functional data for each of the four processing strategies generated from each of the four processing pipelines. As mentioned earlier, these derivatives were all generated using CPAC. Although the calculation of the derivatives were the same for every pipeline, there were differences in each pipeline as to when each derivative was registered to standard space and when smoothing was applied. In every case the final resolution of the calculated derivatives is 3x3x3 mm<sup>3</sup>.

### Approach 1

For CCS, CPAC, and DPARSF, the derivatives listed below were calculated in native space using unsmooted functional data. The results were then written into template space (MNI152) and spatially smoothed with a 6-mm FWHM Gaussian kernel. The registration and smoothing were performed using steps specific to each pipeline.

* Amplitude of low frequnecy fluctuations (ALFF)
* Fractional ALFF (fALFF)
* Regional homogeniety (REHO)
* 10 intrinsic connectivity networks extracted using dual regression

In contrast, the derivatives listed below were calculated on the unsmoothed functional data in template (MNI152) space and then smoothed with a 6-mm FWHM Gaussian kernel.

* Weighted and binarized degeree centrality
* Weighted and binarized eigenvector centrality
* Local functional connectivity density (lFCD)
* Voxel-mirrored homotopic connectivity (VMHC)

Note as mentioned earlier VMHC was calculated on the functional data registered to the symmetric standard MNI152 brain. 

### Approach 2

In the NIAK pipeline, the functional data was written into template space and spatially smoothed with a 6-mm FWHM Guassian kernel prior to calculating the statistical derivatives.

### <a name="regions_of_interest">Regions of Interest</a>

We also extracted mean time-series for several sets of regions-of-interests. In each case, the mean time-series was taken from functional data already registered in standard space for every pipeline. More specifically, time series were extracted for seven ROI atlases:

* Automated Anatomical Labelling
* Eickhoff-Zilles
* Harvard-Oxford
* Talaraich and Tournoux
* Dosenbach 160
* Craddock 200
* Craddock 400

### <a name="min_preproc">Minimally Preprocessed Data</a>

Minimally preprocessed data is only available for the C-PAC pipeline and was processed using only the following steps:

1. Slice timing correction
2. Realignment to correct for motion
3. Written into template space at 3x3x3 mm<sup>3</sup> isotropic resolution

## References

[^1]: Friston, K.J., Williams, S., Howard, R., Frackowiak, R.S., Turner, R., 1996. Movement-related effects in fMRI time-series. Magn Reson Med 35, 346-355.
[^2]: Zijdenbos, A. P., Forghani, R., & Evans, A. C. (2002). Automatic" pipeline" analysis of 3-D MRI data for clinical trials: application to multiple sclerosis. Medical Imaging, IEEE Transactions on, 21(10), 1280-1291.
[^3]: Lund
[^4]: Fox 2005
[^5]: Behzadi et al., 2007
[^6]: Chai et al., 2012
