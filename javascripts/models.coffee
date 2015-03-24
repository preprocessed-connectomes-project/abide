
class Image

  constructor: (data) ->

    # Dimensions of image must always be passed
    [@x, @y, @z] = data.dims

    # Images loaded from a binary volume already have 3D data, and we 
    # just need to clean up values and swap axes (to reverse x and z 
    # relative to xtk).
    if 'data3d' of data
      @min = 0
      @max = 0
      @data = []
      for i in [0...@x]
        @data[i] = []
        for j in [0...@y]
          @data[i][j] = []
          for k in [0...@z]
            value = Math.round(data.data3d[i][j][k]*100)/100
            @max = value if value > @max
            @min = value if value < @min
            @data[i][j][k] = value

    # Load from JSON format. The format is kind of clunky and could be improved.
    else if 'values' of data
      [@max, @min] = [data.max, data.min]
      vec = Transform.jsonToVector(data)
      @data = Transform.vectorToVolume(vec, [@x, @y, @z])

    # Otherwise initialize a blank image.
    else
      @min = 0
      @max = 0
      @data = @empty()

    # If peaks are passed, construct spheres around them
    if 'peaks' of data
      @addSphere(Transform.atlasToImage([p.x, p.y, p.z]), p.r ?= 3, p.value ?= 1) for p in data.peaks
      @max = 2   # Very strange bug causes problem if @max is < value in addSphere();
             # setting to twice the value seems to work.


  # Return an empty volume of current image dimensions
  empty: () ->
    vol = []
    for i in [0...@x]
      vol[i] = []
      for j in [0...@y]
        vol[i][j] = []
        for k in [0...@z]
          vol[i][j][k] = 0
    return vol


  # Add a sphere of radius r at the provided coordinates. Coordinates are specified
  # in image space (i.e., where x/y/z are indexed from 0 to the number of voxels in
  # each plane).
  addSphere: (coords, r, value=1) ->
    return if r <= 0
    [x, y, z] = coords.reverse()
    return unless x? and y? and z?
    for i in [-r..r]
      continue if (x-i) < 0 or (x+i) > (@x - 1)
      for j in [-r..r]
        continue if (y-j) < 0 or (y+j) > (@y - 1)
        for k in [-r..r]
          continue if (z-k) < 0 or (z+k) > (@z - 1)
          dist = i*i + j*j + k*k
          @data[i+x][j+y][k+z] = value if dist < r*r
    return false


  # Need to implement resampling to allow display of images of different resolutions
  resample: (newx, newy, newz) ->


  # Slice the volume along the specified dimension (0 = x, 1 = y, 2 = z) at the
  # specified index and return a 2D array.
  slice: (dim, index) ->
    switch dim
        when 0
          slice = []
          for i in [0...@x]
            slice[i] = []
            for j in [0...@y]
              slice[i][j] = @data[i][j][index]
        when 1
          slice = []
          for i in [0...@x]
            slice[i] = @data[i][index]
        when 2
          slice = @data[index]
    return slice

  dims: ->
    return [@x, @y, @z]



class Layer
  
  # In addition to basic properties we attach to current Layer instance,
  # save the options hash itself. This allows users to extend the 
  # viewer by passing custom options; e.g., images can store a 'download'
  # parameter that indicates whether each image can be downloaded or not.
  constructor: (@image, options) ->

    # Image defaults
    options = $.extend(true, {
      colorPalette: 'red'
      sign: 'positive'
      visible: true
      opacity: 1.0
      cache: false
      download: false
      positiveThreshold: 0
      negativeThreshold: 0
      description: ''
      intent: 'Value:'  # The meaning of the values in the image
      }, options)

    @name = options.name
    @sign = options.sign
    @colorMap = @setColorMap(options.colorPalette)
    @visible = options.visible
    @threshold = @setThreshold(options.negativeThreshold, options.positiveThreshold)
    @opacity = options.opacity
    @download = options.download
    @intent = options.intent
    @description = options.description


  hide: ->
    @visible = false


  show: ->
    @visible = true


  toggle: ->
    @visible = !@visible


  slice: (view, viewer) ->
    # get the right 2D slice from the Image
    data = @image.slice(view.dim, viewer.coords_ijk[view.dim])
    # Threshold if needed
    data = @threshold.mask(data)
    return data


  setColorMap: (palette = null, steps = null) ->
    @palette = palette
    # Color mapping here is a bit non-intuitive, but produces
    # nicer results for the end user.
    if @sign == 'both'
      ### Instead of using the actual min/max range, we find the
      largest absolute value and use that as the bound for
      both signs. This preserves color maps where 0 is
      meaningful; e.g., for hot and cold, we want blues to
      be negative and reds to be positive even when
      abs(min) and abs(max) are quite different.
      BUT if min or max are 0, then implicitly fall back to
      treating mode as if it were 'positive' or 'negative' ###
      maxAbs = Math.max(@image.min, @image.max)
      min = if @image.min == 0 then 0 else -maxAbs
      max = if @image.max == 0 then 0 else maxAbs
    else
      # If user wants just one sign, mask out the other and
      # compress the entire color range into values of one sign.
      min = if @sign == 'positive' then 0 else @image.min
      max = if @sign == 'negative' then 0 else @image.max
    @colorMap = new ColorMap(min, max, palette, steps)


  setThreshold: (negThresh = 0, posThresh = 0) ->
    @threshold = new Threshold(negThresh, posThresh, @sign)


  # Update the layer's settings from provided object.
  update: (settings) ->
    # Handle settings that take precedence first
    @sign = settings['sign'] if 'sign' of settings

    # Now everything else
    nt = 0
    pt = 0
    for k, v of settings
      switch k
        when 'colorPalette' then @setColorMap(v)
        when 'opacity' then @opacity = v
        when 'image-intent' then @intent = v
        when 'pos-threshold' then pt = v
        when 'neg-threshold' then nt = v
        when 'description' then @description = v
    @setThreshold(nt, pt, @sign)


  # Return current settings as an object
  getSettings: () ->
    nt = @threshold.negThresh
    pt = @threshold.posThresh
    nt or= 0.0
    pt or= 0.0
    settings =
      colorPalette: @palette
      sign: @sign
      opacity: @opacity
      'image-intent': @intent
      'pos-threshold': pt
      'neg-threshold': nt
      'description': @description
    return settings



# Stores and manages all currently loaded layers.
class LayerList

  constructor: () ->
    @clearLayers()


  # Add a new layer and (optionally) activate it
  addLayer: (layer, activate = true) ->
    @layers.push(layer)
    @activateLayer(@layers.length-1) if activate


  # Delete the layer at the specified index and activate
  # the one above or below it if appropriate. If target is 
  # an integer, treat as index of layer in array; otherwise 
  # treat as the name of the layer to remove.
  deleteLayer: (target) ->
    index = if String(target).match(/^\d+$/) then parseInt(target)
    else
      index = (i for l, i in @layers when l.name == target)[0]
    @layers.splice(index, 1)
    if @layers.length? and not @activeLayer?
      newInd = if index == 0 then 1 else index - 1
      @activateLayer(newInd)
      

  # Delete all layers
  clearLayers: () ->
    @layers = []
    @activeLayer = null


  # Activate the layer at the specified index
  activateLayer: (index) ->
    @activeLayer = @layers[index]


  # Update the active layer's settings from passed object
  updateActiveLayer: (settings) ->
    @activeLayer.update(settings)


  # Return just the names of layers
  getLayerNames: () ->
    return (l.name for l in @layers)


  # Return a boolean array of all layers' visibilities
  getLayerVisibilities: () ->
    return (l.visible for l in @layers)


  # Return the index of the active layer
  getActiveIndex: () ->
    return @layers.indexOf(@activeLayer)


  # Return the next unused color from the palette list. If all 
  # are in use, return a random palette.
  getNextColor: () ->
    used = (l.palette for l in @layers when l.visible)
    palettes = Object.keys(ColorMap.PALETTES)
    free = palettes.diff(used)
    return if free.length then free[0] else palettes[Math.floor(Math.random()*palettes.length)]


  # Resort the layers so they match the order in the input
  # array. Layers in the input are specified by name.
  # If destroy is true, will remove any layers not passed in.
  # Otherwise will preserve the order of unspecified layers,
  # Slotting unspecified layers ahead of specified ones
  # when conflicts arise. If newOnTop is true, new layers
  # will appear above old ones.
  sortLayers: (newOrder, destroy = false, newOnTop = true) ->
    newLayers = []
    counter = 0
    n_layers = @layers.length
    n_new = newOrder.length
    for l, i in @layers
      ni = newOrder.indexOf(l.name)
      if ni < 0
        if destroy
          continue
        else
          ni = i
          ni += n_new if newOnTop
          counter += 1
      else unless (destroy or newOnTop)
        ni += counter
      newLayers[ni] = l
    @layers = newLayers



# Provides thresholding/masking functionality.
class Threshold

  constructor: (@negThresh, @posThresh, @sign = 'both') ->


  # Mask out any voxel values below/above thresholds.
  mask: (data) ->
    return data if @posThresh is 0 and @negThresh is 0 and @sign == 'both'
    # Zero out any values below threshold or with wrong sign
    res = []
    for i in [0...data.length]
      res[i] = data[i].map (v) =>
        if (@negThresh < v < @posThresh) or (v < 0 and @sign == 'positive') or (v > 0 and @sign == 'negative') then 0 else v
    return res


# Various transformations between different coordinate frames.
# Note that right now the atlas-related transformations are
# hardcoded for MNI 2x2x2 space; need to generalize this!
Transform =

  # Takes compressed JSON-encoded image data as input and reconstructs
  # into a dense 1D vector, indexed from 0 to the total number of voxels.
  jsonToVector: (data) ->
    v = new Array(data.dims[0] * data.dims[1] * data.dims[2])
    v[i] = 0 for i in [0...v.length]
    for i in [0...data.values.length]
      curr_inds = data.indices[i]
      for j in [0...curr_inds.length]
          v[curr_inds[j] - 1] = data.values[i]
    return(v)

  # Reshape a 1D vector of all voxels into a 3D volume with specified dims.
  vectorToVolume: (vec, dims) ->
    vol = []
    for i in [0...dims[0]]
      vol[i] = []
      for j in [0...dims[1]]
        vol[i][j] = []
        for k in [0...dims[2]]
          vol[i][j][k] = 0
          sliceSize = dims[1] * dims[2]
    for i in [0...vec.length]
      continue if typeof vec[i] is `undefined`
      x = Math.floor(i / sliceSize)
      y = Math.floor((i - (x * sliceSize)) / dims[2])
      z = i - (x * sliceSize) - (y * dims[2])
      vol[x][y][z] = vec[i]
    return(vol)

  # Generic coordinate transformation function that takes an input
  # set of coordinates and a matrix to use in the transformation.
  # Depends on the Sylvester library.
  transformCoordinates: (coords, matrix, round = true) ->
    m = $M(matrix)
    coords = coords.slice(0)  # Don't modify in-place
    coords.push(1)
    v = $V(coords)
    res = []
    m.x(v).each (e) ->
      e = Math.round(e) if round
      res.push(e)
    return res

  # Transformation matrix for viewer space --> atlas (MNI 2mm) space
  viewerToAtlas: (coords) ->
    matrix = [[180, 0, 0, -90], [0, -218, 0, 90], [0, 0, -180, 108]]
    return @transformCoordinates(coords, matrix)

  atlasToViewer: (coords) ->
    matrix = [[1.0/180, 0, 0, 0.5], [0, -1.0/218, 0, 90.0/218], [0, 0, -1.0/180, 108.0/180]]
    return @transformCoordinates(coords, matrix, false)

  # Transformation matrix for atlas (MNI 2mm) space --> image (0-indexed) space
  atlasToImage: (coords) ->
    matrix = [[-0.5, 0, 0, 45], [0, 0.5, 0, 63], [0, 0, 0.5, 36]]
    return @transformCoordinates(coords, matrix)

  # Transformation matrix for image space --> atlas (MNI 2mm) space
  imageToAtlas: (coords) ->
    matrix = [[-2, 0, 0, 90], [0, 2, 0, -126], [0, 0, 2, -72]]
    return @transformCoordinates(coords, matrix)