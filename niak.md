---
layout: page
title: niak
---

#The NeuroImaging Analysis Kit (NIAK)

**The NIAK is a free and open-source software developed since 2008 for the preprocessing and data mining of large functional neuroimaging samples. It is compatible with both the GNU Octave[^1] and Matlab[^2] languages. It has a single dependency on the MINC tools[^3]. The implementation of tools in NIAK is modular, and the integration of several tools into complex multistep processing "pipelines" is achieved using a framework called the Pipeline System for Octave and Matlab (PSOM) (Bellec et al. 2012)[^4]. In particular, thanks to PSOM, NIAK pipelines can be executed using parallel resources in high-performance computing environments.**

The ABIDE sample was preprocessed using the NIAK release 0.7.1 (Bellec et al. HBM 2011, NIAK website)[^5]. 

No volumes were suppressed at the beginning of each functional run and no correction was applied for inter-slice difference in acquisition time. A single non-uniformity field was estimated based on the median volume of each functional run using the N3 method[`^], and applied to all volumes in the run. 

The parameters of a rigid-body motion was estimated for each time frame using the median volume of the run as a target. The median fMRI volume was was also coregistered with a T1 individual scan using Minctracc (Collins et al. 1997)[^7], which was itself non-linearly transformed to the Montreal Neurological Institute (MNI) template (Fonov et al 2011)[^8] using the CIVET pipeline (Zijdenbos et al. 2002)[^9]. The MNI asymmetric template was generated from the ICBM152 sample of 152 young adults, after 40 iterations of non-linear coregistration. The rigid-body transform, fMRI-to-T1 transform and T1-to-stereotaxic transform were all combined, and the functional volumes were resampled in the MNI space at a 3 mm isotropic resolution. 

The “scrubbing” method of Power et al. 2012[^10], was used to remove the volumes with excessive motion (frame displacement greater than 0.5). The following nuisance parameters were regressed out from the time series at each voxel: slow time drifts (basis of discrete cosines with a 0.01 Hz high-pass cut-off), average signals in conservative masks of the white matter and the lateral ventricles as well as the first principal components (95\% energy) of the six rigid-body motion parameters and their squares (Lund et al. 2001, Giove et al. 2009)[^11]'[^12]. 

The fMRI volumes were finally spatially smoothed with a 6 mm isotropic Gaussian blurring kernel. A more detailed description of the pipeline can be found on the NIAK website[^5].

##References
[^1]:http://www.gnu.org/software/octave/
[^2]:MATLAB and Statistics Toolbox Release 2012b, The MathWorks, Inc., Natick, Massachusetts, United States.
[^3]:http://www.bic.mni.mcgill.ca/ServicesSoftware/ServicesSoftwareMincToolKit
[^4]: Bellec, P., Lavoie-Courchesne, S., Dickinson, P., Lerch, J. P., Zijdenbos, A. P., & Evans, A. C. (2012). The pipeline system for Octave and Matlab (PSOM): a lightweight scripting framework and execution engine for scientific workflows. Frontiers in neuroinformatics, 6.
[^5]: https://code.google.com/p/niak/
[^6]: Sled, J. G., Zijdenbos, A. P., & Evans, A. C. (1998). A nonparametric method for automatic correction of intensity nonuniformity in MRI data. Medical Imaging, IEEE Transactions on, 17(1), 87-97.
[^7]: Collins, D. L., & Evans, A. C. (1997). Animal: validation and applications of nonlinear registration-based segmentation. International Journal of Pattern Recognition and Artificial Intelligence, 11(08), 1271-1294.
[^8]: Fonov, V., Evans, A. C., Botteron, K., Almli, C. R., McKinstry, R. C., & Collins, D. L. (2011). Unbiased average age-appropriate atlases for pediatric studies. Neuroimage, 54(1), 313-327.
[^9]: Zijdenbos, A. P., Forghani, R., & Evans, A. C. (2002). Automatic" pipeline" analysis of 3-D MRI data for clinical trials: application to multiple sclerosis. Medical Imaging, IEEE Transactions on, 21(10), 1280-1291.
[^10]: Power, J. D., Barnes, K. A., Snyder, A. Z., Schlaggar, B. L., & Petersen, S. E. (2012). Spurious but systematic correlations in functional connectivity MRI networks arise from subject motion. Neuroimage, 59(3), 2142-2154.
[^11]: Lund, T. E. (2001). fcMRI—Mapping functional connectivity or correlating cardiac‐induced noise?. Magnetic Resonance in Medicine, 46(3), 628-628.
[^12]: Giove, F., Gili, T., Iacovella, V., Macaluso, E., & Maraviglia, B. (2009). Images-based suppression of unwanted global signals in resting-state functional connectivity studies. Magnetic resonance imaging, 27(8), 1058-1064.
