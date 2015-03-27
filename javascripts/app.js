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

	viewer.addPipelineSelect('#select_pipeline')
	viewer.addStrategySelect('#select_strategy')
	viewer.addColorSelect('#select_color');
	viewer.addSignSelect('#select_sign')
	viewer.addDataField('voxelValue', '#data_current_value')
	viewer.addDataField('currentCoords', '#data_current_coords')
	viewer.addTextField('image-intent', '#image_intent')


	loadSelectedImage();
});


function loadSelectedImage() {

    viewer.clearImages();
    viewer.clear();

	pipeline = $('#select_pipeline').val();
	strategy = $('#select_strategy').val();
	patient = $('#select_patient').val();

	images = [
		 {
		 	'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/'+ pipeline +'/' + strategy + '/func_mean/' + patient + '_func_mean.nii.gz',
		 	'name': 'mean functional',
		 	'colorPalette': 'grayscale',
		 	'intent': 'Intensity:'
		},
		{
			'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/'+ pipeline +'/' + strategy + '/alff/' + patient + '_alff.nii.gz',
			'name': 'ALFF',
			'colorPalette': 'red-yellow-blue',
			'intent': 'z-score:'
		},
		{
			'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/'+ pipeline +'/' + strategy + '/falff/' + patient + '_falff.nii.gz',
			'name': 'fALFF',
			'colorPalette': 'navy',
			'intent': 'z-score:'
		},
		{
			'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/'+ pipeline +'/' + strategy + '/vmhc/' + patient + '_vmhc.nii.gz',
			'name': 'VMHC',
			'colorPalette': 'aqua',
			'intent': 'z-score:'
		},
		{
			'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/'+ pipeline +'/' + strategy + '/lfcd/' + patient + '_lfcd.nii.gz',
			'name': 'LFCD',
			'colorPalette': 'lime',
			'intent': 'z-score:'
		},
		{
			'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/'+ pipeline +'/' + strategy + '/reho/' + patient + '_reho.nii.gz',
			'name': 'REHO',
			'colorPalette': 'purple',
			'intent': 'z-score:'
		},
		{
			'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/'+ pipeline +'/' + strategy + '/degree_weighted/' + patient + '_degree_weighted.nii.gz',
			'name': 'Degree Weighted',
			'colorPalette': 'yellow',
			'intent': 'z-score:'
		},
		{
			'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/'+ pipeline +'/' + strategy + '/degree_binarize/' + patient + '_degree_binarize.nii.gz',
			'name': 'Degree Binarized',
			'colorPalette': 'blue',
			'intent': 'z-score:'
		},
		{
			'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/'+ pipeline +'/' + strategy + '/eigenvector_weighted/' + patient + '_eigenvector_weighted.nii.gz',
			'name': 'Eigenvector Weighted',
			'colorPalette': 'green',
			'intent': 'Intensity'
		},
		{
			'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/'+ pipeline +'/' + strategy + '/eigenvector_binarize/' + patient + '_eigenvector_binarize.nii.gz',
			'name': 'Eigenvector Binarized',
			'colorPalette': 'red',
			'intent': 'Intensity:'
		}
	];

	viewer.loadImages(images);


};