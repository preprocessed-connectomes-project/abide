jQuery(document).ready(function() {

	viewer = new Viewer('#layer_list', '.layer_settings');
	viewer.addView('#view_axial', Viewer.AXIAL);
	viewer.addView('#view_coronal', Viewer.CORONAL);
	viewer.addView('#view_sagittal', Viewer.SAGITTAL);
	viewer.addSlider('opacity', '.slider#opacity', 'horizontal', 0, 1, 1, 0.05);
	viewer.addSlider('pos-threshold', '.slider#pos-threshold', 'horizontal', 0, 1, 0, 0.01);
	viewer.addSlider('neg-threshold', '.slider#neg-threshold', 'horizontal', 0, 1, 0, 0.01);
	viewer.addSlider("nav-xaxis", ".slider#nav-xaxis", "horizontal", 0, 1, 0.5, 0.01, Viewer.XAXIS);
	viewer.addSlider("nav-yaxis", ".slider#nav-yaxis", "vertical", 0, 1, 0.5, 0.01, Viewer.YAXIS);
	viewer.addSlider("nav-zaxis", ".slider#nav-zaxis", "vertical", 0, 1, 0.5, 0.01, Viewer.ZAXIS);

	viewer.addPipelineSelect('#select_Pipeline');
	viewer.addStrategySelect('#select_strategy');
	viewer.addColorSelect('#select_color');
	viewer.addSignSelect('#select_sign')
	viewer.addDataField('voxelValue', '#data_current_value')
	viewer.addDataField('currentCoords', '#data_current_coords')
	viewer.addTextField('image-intent', '#image_intent')
	viewer.clear()   // Paint canvas background while images load
// images = [
// 	{
// 		'url': 'data/MNI152_3mm.nii.gz',
// 		'name': 'MNI152 3mm',
// 		'colorPalette': 'grayscale',
// 		'cache': false,
// 		'intent': 'Intensity:'
// 	},
// 	{
// 		'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/filt_global/alff/OHSU_0050147_alff.nii.gz',
// 		'name': 'ALFF',
// 		'colorPalette': 'red-yellow-blue',
// 		'intent': 'z-score:'
// 	},
// 	{
// 		'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/filt_global/falff/OHSU_0050147_falff.nii.gz',
// 		'name': 'fALFF',
// 		'colorPalette': 'red-yellow-blue',
// 		'intent': 'z-score:'
// 	},
// 	{
// 		'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/filt_global/vmhc/OHSU_0050147_vmhc.nii.gz',
// 		'name': 'VMHC',
// 		'colorPalette': 'red-yellow-blue',
// 		'intent': 'z-score:'
// 	},
// 	{
// 		'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/filt_global/lfcd/OHSU_0050147_lfcd.nii.gz',
// 		'name': 'LFCD',
// 		'colorPalette': 'red-yellow-blue',
// 		'intent': 'z-score:'
// 	},
// 	{
// 		'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/filt_global/reho/OHSU_0050147_reho.nii.gz',
// 		'name': 'REHO',
// 		'colorPalette': 'red-yellow-blue',
// 		'intent': 'z-score:'
// 	},
// 	{
// 		'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/filt_global/degree_weighted/OHSU_0050147_degree_weighted.nii.gz',
// 		'name': 'Degree Weighted',
// 		'colorPalette': 'red-yellow-blue',
// 		'intent': 'z-score:'
// 	},
// 	{
// 		'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/filt_global/degree_binarize/OHSU_0050147_degree_binarize.nii.gz',
// 		'name': 'Degree Binarized',
// 		'colorPalette': 'red-yellow-blue',
// 		'intent': 'z-score:'
// 	},
// 	{
// 		'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/filt_global/eigenvector_weighted/OHSU_0050147_eigenvector_weighted.nii.gz',
// 		'name': 'Eigenvector Weighted',
// 		'colorPalette': 'red-yellow-blue',
// 		'intent': 'Intensity:'
// 	},
// 	{
// 		'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/filt_global/eigenvector_binarize/OHSU_0050147_eigenvector_binarize.nii.gz',
// 		'name': 'Eigenvector Binarized',
// 		'colorPalette': 'red-yellow-blue',
// 		'intent': 'Intensity:'
// 	}
// ]
// viewer.loadImages(images);

});
