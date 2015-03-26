---
layout: page
title: ABIDE Preprocessed Viewer
---
          
<link href="stylesheets/style.css" media="screen" rel="stylesheet" type="text/css" />
<link href="//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css" rel="stylesheet">
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

	<div>

		<div id='view_axial' class='inline'>
			<canvas height='264' id='axial_canvas' width='220'></canvas>
			<div class='slider nav-slider-vertical' id='nav-zaxis'></div>
		</div>

		<div id='view_coronal' class='inline'>
			<canvas height='220' id='cor_canvas' width='220'></canvas>
			<div class='slider nav-slider-vertical' id='nav-yaxis'></div>
		</div>

		<div id='view_sagittal' class='inline'>
			<canvas height='220' id='sag_canvas' width='264'></canvas>
			<div class='slider nav-slider-horizontal' id='nav-xaxis'></div>
		</div>
	</div>


	<div>
		<div class="data_display_row inline">
			<div>Coordinates:</div>
			<div id="data_current_coords"></div>
		</div>
		<div class="data_display_row inline">
			<div>Initial value</div>
			<div id="data_current_value"></div>
		</div>
	</div>

	<div>
		<div id="data_panel" class="inline">
			<div>Pipeline:<select id="select_pipeline"></select></div>
			<div>Strategy:<select id="select_strategy"></select></div>
			<div>Patient ID: <input id="select_patient" type="text" value="OHSU_0050147"></div>
			<div><button onclick="loadSelectedImage()">Load Image</button></div>
		</div>

		<div id="layer_panel" class='inline'>
			<div id="layer_list_panel">
				<div>Layers</div>
				<div id="layer_visible_list"></div>
				<ul id="layer_list" class="layer_settings">
				</ul>
			</div>
		</div>

		<div id="layer_settings_panel" class='inline'>
			Color palette:<select id="select_color"></select>
			Positive/Negative:<select id="select_sign"></select>
			Opacity:<div class='slider' id='opacity'></div>
			Pos. threshold:<div class='slider' id='pos-threshold'></div>
			Neg. threshold: <div class='slider' id='neg-threshold'></div>
		</div>
	</div>

</div>