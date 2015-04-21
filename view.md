---
layout: page
title: ABIDE Preprocessed Viewer
---

<link type="text/css" href="stylesheets/volume-viewer-demo.css" rel="Stylesheet" />
<link type="text/css" href="stylesheets/ui-darkness/jquery-ui-1.8.10.custom.css" rel="Stylesheet" />

<div class='container relative-pos'>

    <script id="overlay-ui-template" type="x-volume-ui-template">
      <div id="overlay_viewer" class="overlay-viewer-display inline top"></div>
    </script>


  <script id="hidden-ui-template" type="x-hidden-ui-template">
    <div class="hide volume-viewer-hidden"></div>
  </script>

  <script id="volume-ui-template" type="x-volume-ui-template">
    <div class="hide volume-viewer-display"></div>
      
    <div class="bot right">
      <div class="coords">
        <div class="control-heading" id="voxel-coordinates-heading-">
          Voxel Coordinates: 
        </div>
        <div class="voxel-coords" data-volume-id="{{VOLID}}">
          I:<input id="voxel-i-" class="control-inputs" readonly="readonly">
          J:<input id="voxel-j-" class="control-inputs" readonly="readonly">
          K:<input id="voxel-k-" class="control-inputs" readonly="readonly">
        </div>
        <div class="control-heading" id="world-coordinates-heading-">
          World Coordinates: 
        </div>
        <div class="world-coords" data-volume-id="{{VOLID}}">
          X:<input id="world-x-" class="control-inputs" readonly="readonly">
          Y:<input id="world-y-" class="control-inputs" readonly="readonly">
          Z:<input id="world-z-" class="control-inputs" readonly="readonly">
        </div>
      </div>

      <div id="intensity-value-div-{{VOLID}}">
        <span class="control-heading" data-volume-id="{{VOLID}}">
          Value: 
        </span>
        <span id="intensity-value-{{VOLID}}" class="intensity-value"></span>
      </div>
      
      <div id="color-map-{{VOLID}}">
        <span class="control-heading" id="color-map-heading">
          Color Map: 
        </span>
      </div>

      <div class="threshold-div" data-volume-id="{{VOLID}}">
        <div id="threshold-heading" class="control-heading">Threshold: </div>
        <div class="thresh-inputs">
          <input id="min-threshold-" class="control-inputs thresh-input-left" readonly="readonly"/>
          <input id="max-threshold-" class="control-inputs thresh-input-right" readonly="readonly"/>
        </div> 
        <div class="slider volume-viewer-threshold" id="threshold-slider-{{VOLID}}"></div>
      </div>

      <div id="time-{{VOLID}}" class="time-div" data-volume-id="{{VOLID}}">
        <span class="control-heading">Time:</span>
        <input class="control-inputs" value="0" id="time-val-{{VOLID}}"/>
        <div class="slider volume-viewer-threshold" id="time-slider-{{VOLID}}"></div>
        <input type="checkbox" class="button" id="play-{{VOLID}}"><label for="play-{{VOLID}}">Play</label>
      </div>
    </div>
  </script>

  <div id="loading" style="display: none"><img src="images/ajax-loader.gif" /></div>
  <div id="brainbrowser-wrapper" style="display:none">
    <div id="volume-viewer">
      <div id="global-controls" class=""></div>
      <div id="brainbrowser"></div>
    </div>
  </div>


  <div class="bot">
    <div>
      <span class="control-heading">Pipeline:</span>
      <select id="pipeline">
        <option value="cpac">CPAC</option>
        <option value="ccs">ccs</option>
        <option value="dparsf">dparsf</option>
        <option value="dparsf">niak</option>
      </select> 
    </div>

    <div>
      <span class="control-heading">Strategy:</span>
      <select id="strategy">
        <option value="filt_global">filt_globa</option>
        <option value="filt_noglobal">filt_noglobal</option>
        <option value="nofilt_global">nofilt_global</option>
        <option value="nofilt_noglobal">nofilt_noglobal</option>
      </select> 
    </div>

    <div>
      <span class="control-heading">Derivative:</span>
      <select id="derivative">
        <option value="alff">falff</option>
        <option value="degree_binarize">degree binarize</option>
        <option value="degree_weighted">degree weighted</option>
        <option value="eigenvector_binarize">eigenvector binarize</option>
        <option value="eigenvector_weighted">eigenvector weighted</option>
        <option value="falff">falff</option>
        <option value="reho">reho</option>
        <option value="vmhc">vmhc</option>
        <option value="lfcd">lfcd</option>
        <option value="dual_regression">dual regression</option>
      </select> 
    </div>

    <div>
    <span class="control-heading">Subject:</span>
    <input type="text" id="subject" value="OHSU_0050147">
    </div>
    <input type="submit" onclick="loadFile()" value="Load data" class="button">

  </div>

<script src="javascripts/brainbrowser/jquery-1.6.4.min.js"></script>
<script src="javascripts/brainbrowser/jquery-ui-1.8.10.custom.min.js"></script>
<script src="javascripts/brainbrowser/ui.js"></script>
<script src="javascripts/brainbrowser/gunzip.min.js"></script>
<script src="javascripts/brainbrowser/brainbrowser.js"></script>
<script src="javascripts/brainbrowser/core/tree-store.js"></script>
<script src="javascripts/brainbrowser/lib/config.js"></script>
<script src="javascripts/brainbrowser/lib/utils.js"></script>
<script src="javascripts/brainbrowser/lib/events.js"></script> 
<script src="javascripts/brainbrowser/lib/loader.js"></script> 
<script src="javascripts/brainbrowser/lib/color-map.js"></script> 
<script src="javascripts/brainbrowser/volume-viewer.js"></script>
<script src="javascripts/brainbrowser/volume-viewer/lib/display.js"></script>
<script src="javascripts/brainbrowser/volume-viewer/lib/panel.js"></script>
<script src="javascripts/brainbrowser/volume-viewer/lib/utils.js"></script>
<script src="javascripts/brainbrowser/volume-viewer/modules/loading.js"></script>
<script src="javascripts/brainbrowser/volume-viewer/modules/rendering.js"></script>
<script src="javascripts/brainbrowser/volume-viewer/volume-loaders/overlay.js"></script>
<script src="javascripts/brainbrowser/volume-viewer/volume-loaders/minc.js"></script>
<script src="javascripts/brainbrowser/volume-viewer/volume-loaders/nifti1.js"></script>
<script src="javascripts/brainbrowser/volume-viewer-demo.config.js"></script> 
<script src="javascripts/brainbrowser/volume-viewer-demo2.js"></script> 

</div>

