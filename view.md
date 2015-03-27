---
layout: page
title: ABIDE Preprocessed Viewer
---
          
<link href="stylesheets/style.css" media="screen" rel="stylesheet" type="text/css" />
<link href="stylesheets/jquery-ui.css" media="screen" rel="stylesheet" type="text/css" />
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

		<div id='view_axial' class='column inline'>
			<canvas id='axial_canvas' width='230' height='280'></canvas>
			<div class='slider nav-slider-vertical' id='nav-zaxis'></div>
		</div>

		<div id='view_coronal' class='column inline'>
			<canvas id='cor_canvas' width='230' height='280'></canvas>
			<div class='slider nav-slider-vertical' id='nav-yaxis'></div>
		</div>

		<div id='view_sagittal' class='coulmn inline'>
			<canvas id='sag_canvas' width='300' height='265'></canvas>
			<div class='slider nav-slider-horizontal' id='nav-xaxis'></div>
		</div>
	</div>


	<div>
		<div class="inline data_display_row">
			<div>Coordinates:</div>
			<div id="data_current_coords"></div>
		</div>
		<div class="inline data_display_row">
			<div>Value:</div>
			<div id="data_current_value" ></div>
		</div>
	</div>

	<div>
		<div id="data_panel" class="column inline">
			<h2>Data</h2>
			<div>Pipeline:<select id="select_pipeline" class="field"></select></div>
			<div>Strategy:<select id="select_strategy" class="field"></select></div>
			<div>Patient ID: <input id="select_patient" class="field" type="text" value="OHSU_0050147"></div>
			<div><button onclick="loadSelectedImage()">Load Image</button></div>
		</div>

		<div id="layer_panel" class='column inline'>
		<h2>Layers</h2>
			<div id="layer_list_panel">
				<div id="layer_visible_list"></div>
				<ul id="layer_list">
				</ul>
			</div>
		</div>

		<div class='column inline'>
			<h2>Settings</h2>
			<div> Color palette:<select id="select_color" class="field"></select></div>
			<div>Positive/Negative:<select id="select_sign" class="field"></select></div>
			<div>Opacity:<div class='slider' id='opacity'></div></div>
			<div> Pos. threshold:<div class='slider' id='pos-threshold'></div></div>
			<div> Neg. threshold: <div class='slider' id='neg-threshold'></div></div>
		</div>
	</div>

</div>