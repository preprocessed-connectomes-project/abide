---
layout: page
title: ABIDE Preprocessed Viewer
---
          
<link href="stylesheets/style.css" media="screen" rel="stylesheet" type="text/css" />
<link href="stylesheets/bootstrap.min.css" media="screen" rel="stylesheet" type="text/css" />
<script src="javascripts/panzoom.js" type="text/javascript"></script>
<script src="javascripts/jquery.min.js" type="text/javascript"></script>
<script src="javascripts/xtk.js" type="text/javascript"></script>
<script src="javascripts/jquery-ui.min.js" type="text/javascript"></script>
<script src="javascripts/bootstrap.min.js" type="text/javascript"></script>
<script src="javascripts/rainbow.js" type="text/javascript"></script>
<script src="javascripts/sylvester.js" type="text/javascript"></script>
<script src="javascripts/amplify.min.js" type="text/javascript"></script>
<script src="javascripts/viewer.js" type="text/javascript"></script>
<script src="javascripts/app.js" type="text/javascript"></script>

<div class='container'>

	<div id="brainviewer" class="row">
		<div class="col-lg-12">

			<div id='view_coronal' class='col-md-4 viewer' >
				<canvas id='cor_canvas' width='235' height='260'></canvas>
				<div id='nav-yaxis' class='slider nav-slider-vertical'></div>
			</div>

			<div id='view_axial' class='col-md-4 viewer'>
				<canvas id='axial_canvas' width='235' height='260'></canvas>
				<div id='nav-zaxis' class='slider nav-slider-vertical'></div>
			</div>

			<div id='view_sagittal' class='col-md-4 viewer'>
				<canvas id='sag_canvas' width='260' height='235'></canvas>
				<div class='slider nav-slider-horizontal' id='nav-xaxis'></div>
			</div>

		</div>
	</div>

	<div id="coordinatesviewer" class="col-lg-8 marginbot-50">

		<div class="data_display_row col-md-4">
			<div class="data_label">Coordinates:</div>
			<div id="data_current_coords"></div>
		</div>
		<div class="data_display_row col-md-4">
			<div id="image_intent" class="data_label">Initial value:</div>
			<div id="data_current_value"></div>
		</div>
	</div>

	<div id="settings_panel" class="row">
		<div class="col-lg-12 marginbot-50"> 

			<div class="col-md-4">
				<h2 class="marginbot-20">Data</h2>
				<div>Pipeline: </div>
				<div><select id="select_Pipeline" class="layer_settings options"></select> </div>

				<div>Strategy:</div>
				<div><select id="select_strategy" class="layer_settings options"></select> </div>

				<div>Patient ID:</div>
				<div> <input type="text" id="select_patient" class="layer_settings options" value="OHSU_0050147"></div>
				
				<div><button type="button" onClick="load_nifti()" class="load_btn">Load Image</button></div>
			</div>

			<div id="layer_settings" class="col-md-4">
				<h2 class="marginbot-20">Settings</h2>
				<div id="layer_settings_panel">
					<div>Color palette:</div>
					<div><select id="select_color" class="layer_settings options"></select></div>

					<div>Positive/Negative:</div>
					<select id="select_sign" class="layer_settings options"></select></div>
					<div>Opacity:<div id='opacity' class='slider layer_settings options'></div></div>

					<div>Pos. threshold:<div class='slider layer_settings' id='pos-threshold'></div></div>
					<div> Neg. threshold: <div class='slider layer_settings' id='neg-threshold'></div>
				</div>
			</div>

			<div id="layer_panel" class="col-md-4">
				<div id="layer_list_panel">
					<h2 class="marginbot-20">Layers</h2>
					<div id="layer_visible_list"></div>
					<ul id="layer_list" class="layer_settings"></ul>
					<!-- 		<select name="layer_list" id="layer_list" class="layer_settings" size=5>
					</select> -->
				</div>
			</div>


		</div>
	</div>

</div>

<script>
function load_nifti() {
	viewer.clearImages();
	pipeline = $('#select_Pipeline').val();
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
			'colorPalette': 'red-yellow-blue',
			'intent': 'z-score:'
		},
		{
			'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/'+ pipeline +'/' + strategy + '/vmhc/' + patient + '_vmhc.nii.gz',
			'name': 'VMHC',
			'colorPalette': 'red-yellow-blue',
			'intent': 'z-score:'
		},
		{
			'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/'+ pipeline +'/' + strategy + '/lfcd/' + patient + '_lfcd.nii.gz',
			'name': 'LFCD',
			'colorPalette': 'red-yellow-blue',
			'intent': 'z-score:'
		},
		{
			'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/'+ pipeline +'/' + strategy + '/reho/' + patient + '_reho.nii.gz',
			'name': 'REHO',
			'colorPalette': 'red-yellow-blue',
			'intent': 'z-score:'
		},
		{
			'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/'+ pipeline +'/' + strategy + '/degree_weighted/' + patient + '_degree_weighted.nii.gz',
			'name': 'Degree Weighted',
			'colorPalette': 'red-yellow-blue',
			'intent': 'z-score:'
		},
		{
			'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/'+ pipeline +'/' + strategy + '/degree_binarize/' + patient + '_degree_binarize.nii.gz',
			'name': 'Degree Binarized',
			'colorPalette': 'red-yellow-blue',
			'intent': 'z-score:'
		},
		{
			'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/'+ pipeline +'/' + strategy + '/eigenvector_weighted/' + patient + '_eigenvector_weighted.nii.gz',
			'name': 'Eigenvector Weighted',
			'colorPalette': 'red-yellow-blue',
			'intent': 'Intensity:'
		},
		{
			'url': 'https://s3.amazonaws.com/fcp-indi/data/Projects/ABIDE_Initiative/Outputs/'+ pipeline +'/' + strategy + '/eigenvector_binarize/' + patient + '_eigenvector_binarize.nii.gz',
			'name': 'Eigenvector Binarized',
			'colorPalette': 'red-yellow-blue',
			'intent': 'Intensity:'
		}
	];

	viewer.loadImages(images);
};
</script>
