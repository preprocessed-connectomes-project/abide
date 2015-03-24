class UserInterface

  constructor: (@viewer, @layerListId, @layerSettingClass) ->

    @viewSettings = @viewer.viewSettings
    @components = {}

    # Make layer list sortable, and update the model after sorting.
    $(@layerListId).sortable({
      update: =>  
        layers = ($('.layer_list_item').map ->
          return $(this).text()
        ).toArray()
        @viewer.sortLayers(layers, paint = true)
    })

    # Add event handlers
    $(@layerSettingClass).change((e) =>
      @settingsChanged()
    )

  # Add a slider to the view
  addSlider: (name, element, orientation, min, max, value, step, textField) ->
    slider = new SliderComponent(@, name, element, orientation, min, max, value, step)
    @addTextFieldForSlider(textField, slider) if textField?
    @components[name] = slider

  # Add a text field--either an editable <input> field, or just a regular element
  addTextField: (name, element) ->
    tf = new TextFieldComponent(@, name, element)
    @components[name] = tf

  # Create a text field and bind it to a slider so the user can update/view values directly
  addTextFieldForSlider: (element, slider) ->
    name = slider.name + '_textField'
    tf = new TextFieldComponent(@, name, element, slider)
    slider.attachTextField(tf)


  addColorSelect: (element) ->
    @components['colorPalette'] = new SelectComponent(@, 'colorPalette', element, Object.keys(ColorMap.PALETTES))


  addSignSelect: (element) ->
    @components['sign'] = new SelectComponent(@, 'signSelect', element, ['both', 'positive', 'negative'])


  # Add checkboxes for options to the view. Not thrilled about mixing view and model in
  # this way, but the GUI code needs refactoring anyway, and for now this makes updating
  # much easier.
  addSettingsCheckboxes: (element, settings) ->
    $(element).empty()
    validSettings = {
      panzoom: 'Pan/zoom'
      crosshairs: 'Crosshairs'
      labels: 'Labels'
    }
    for s,v of settings
      if s of validSettings
        checked = if v then ' checked' else ''
        $(element).append("<div class='checkbox_row'><input type='checkbox' class='settings_box' #{checked} id='#{s}'>#{validSettings[s]}</div>")
    $('.settings_box').change((e) =>
      @checkboxesChanged()
    )

  # Call when settings change in the view . Extracts all available settings as a hash 
  # and calls the controller to update the layer model. Note that no validation or 
  # scaling of parameters is done here--the view returns all slider values as they 
  # exist in the DOM and these may need to be transformed later.
  settingsChanged: () ->
    settings = {}
    for name, component of @components
      settings[name] = component.getValue()
    @viewer.updateSettings(settings)

  # Event handler for checkboxes
  checkboxesChanged: () ->
    settings = {}
    for s in $('.settings_box')
      id = $(s).attr('id')
      val = if $(s).is(':checked') then true else false
      settings[id + 'Enabled'] = val
    @viewer.updateViewSettings(settings, true)

  # Sync all components (i.e., UI elements) with model.
  updateComponents: (settings) ->
    for name, value of settings
      if name of @components
        @components[name].setValue(value)

  # Update the threshold sliders using image data. Kind of a crummy way to handle this--
  # really we should use backbone.js or some other framework to bind data to models properly.
  updateThresholdSliders: (image) ->
    if 'pos-threshold' of @components
      @components['pos-threshold'].setRange(0, image.max)
    if 'neg-threshold' of @components
      @components['neg-threshold'].setRange(image.min, 0)

  # Update the list of layers in the view from an array of names and selects
  # the selected layer by index.
  updateLayerList: (layers, selectedIndex) ->
    $(@layerListId).empty()
    for i in [0...layers.length]
      l = layers[i]
      
      visibility_icon = if @viewSettings.visibilityIconEnabled
        "<div class='visibility_icon' title='Hide/show image'><span class='glyphicon glyphicon-eye-open'></i></div>"
      else ''

      deletion_icon = if @viewSettings.deletionIconEnabled
        "<div class='deletion_icon' title='Remove this layer'><span class='glyphicon glyphicon-trash'></i></div>"
      else ''

      download_icon = if true
        "<div class='download_icon' title='Download this image'><span class='glyphicon glyphicon-save'></i></div>"
      else ''


      $(@layerListId).append(
        $("<li class='layer_list_item'>#{visibility_icon}<div class='layer_label'>" + l + 
          "</div>#{download_icon}#{deletion_icon}</li>")
      )
    # Add click event handler to all list items and visibility icons
    $('.layer_label').click((e) =>
      @viewer.selectLayer($('.layer_label').index(e.target))
    )

    # Set event handlers for icon clicks--visibility, download, deletion
    $('.visibility_icon').click((e) =>
      @toggleLayer($('.visibility_icon').index($(e.target).closest('div')))
    )
    $('.deletion_icon').click((e) =>
      if confirm("Are you sure you want to remove this layer?")
        @viewer.deleteLayer($('.deletion_icon').index($(e.target).closest('div')))
    )
    $('.download_icon').click((e) =>
      @viewer.downloadImage($('.download_icon').index($(e.target).closest('div')))
    )

    $(@layerListId).val(selectedIndex)

  # Update the eye closed/open icons in the list based on their current visibility
  updateLayerVisibility: (visible) ->
    return unless @viewSettings.visibilityIconEnabled
    for i in [0...visible.length]
      if visible[i]
        $('.visibility_icon>span').eq(i).removeClass('glyphicon glyphicon-eye-close').addClass('glyphicon glyphicon-eye-open')
      else
        $('.visibility_icon>span').eq(i).removeClass('glyphicon glyphicon-eye-open').addClass('glyphicon glyphicon-eye-close')

  # Sync the selected layer with the view
  updateLayerSelection: (id) ->
    $('.layer_label').eq(id).addClass('selected')
    $('.layer_label').not(":eq(#{id})").removeClass('selected')

  # Toggle the specified layer's visibility
  toggleLayer: (id) ->
    @viewer.toggleLayer(id)



# Presents data to user. Should only include non-interactive fields.
class DataPanel

  constructor: (@viewer) ->
    @fields = {}


  addDataField: (name, element) ->
    @fields[name] = new DataField(@, name, element)


  addCoordinateFields: (name, element) ->
    target = $(element)
    # Insert elements for x/y/z update fields
    for i in [0...2]
      target.append($("<div class='axis_pos' id='axis_pos_#{axis}'></div>"))
    # Add change handler--when any axis changes, update all coordinates
    $('axis_pos').change((e) =>
      for i in [0...2]
        cc = $("#axis_pos_#{i}").val()  # Get current position
        # TODO: ADD VALIDATION--NEED TO ROUND TO NEAREST VALID POSITION
        #     AND MAKE SURE WE'RE WITHIN BOUNDS
        @viewer.coords_abc[i] = Transform.atlasToViewer(cc)
        @viewer.coords_ijk[i] = cc
      @viewer.update()  # Fix
    )


  update: (data) ->
    for k, v of data
      if k of @fields
        # For multi-field coordinate representation, assign each plane
        if k == 'currentCoordsMulti'
          for pos, i of v
            $("plane#{i}_pos").text(pos)
        # Otherwise just set value, handling special cases appropriately
        else
          if k == 'currentCoords'
            v = "[#{v}]"
          $(@fields[k].element).text(v)



class ViewSettings

  ### Stores any settings common to all views--e.g., crosshair preferences,
  dragging/zooming, etc. Individual views can override these settings if view-specific
  options are desired. ###

  constructor: (options) ->
    # Defaults
    @settings = {
      panzoomEnabled: false
      crosshairsEnabled: true
      crosshairsWidth: 1
      crosshairsColor: 'lime'
      labelsEnabled: true
      visibilityIconEnabled: true
      deletionIconEnabled: true
    }
    @updateSettings(options)


  updateSettings: (options) ->
    $.extend(@settings, options)
    for k, v of @settings
      @[k] = v
    @crosshairs = new Crosshairs(@crosshairsEnabled, @crosshairsColor, @crosshairsWidth)



class View

  constructor: (@viewer, @viewSettings, @element, @dim, @labels = true, @slider = null) ->
    @resetCanvas()
    @_jQueryInit()


  # Add a nav slider
  addSlider: (name, element, orientation, min, max, value, step, textField) ->
    @slider = new SliderComponent(@, name, element, orientation, min, max, value, step)
    @viewer.addTextFieldForSlider(textField, @slider) if textField?


  clear: ->
    # Temporarily reset the context state, blank the view, then restore state
    currentState = $.extend(true, {}, @context.getTransform())  # Deep copy
    @context.reset()
    @context.fillStyle = 'black'
    @context.fillRect(0, 0, @width, @height)
    @context.setTransformFromArray(currentState)


  resetCanvas: ->
    # Resets all canvas properties and transformations. Typically this will only need 
    # to be called during construction, but some situations may require reseting 
    # during runtime--e.g., when revealing a hidden canvas (which can't be drawn to
    #  while hidden).
    @canvas = $(@element).find('canvas')
    @width = @canvas.width()
    @height = @canvas.height()
    @context = @canvas[0].getContext("2d")     
    trackTransforms(@context)
    @lastX = @width / 2
    @lastY = @height / 2
    @dragStart = undefined
    @scaleFactor = 1.1
    @clear()
    

  paint: (layer) ->
    @resetCanvas() if @width == 0 # Make sure canvas is visible
    data = layer.slice(this, @viewer)
    cols = layer.colorMap.map(data)
    img = layer.image
    dims = [[img.y, img.z], [img.x, img.z], [img.x, img.y]]
    xCell = @width / dims[@dim][0]
    yCell = @height / dims[@dim][1]
    @xCell = xCell
    @yCell = yCell
    fuzz = 0.5  # Need to expand paint region to avoid gaps
    @context.globalAlpha = layer.opacity
    @context.lineWidth = 1
    for i in [0...dims[@dim][1]]
      for j in [0...dims[@dim][0]]
        continue if typeof data[i][j] is `undefined` | data[i][j] is 0
        xp = @width - (j + 1) * xCell #- xCell
        yp = @height - (i + 1) * yCell
        col = cols[i][j]
        @context.fillStyle = col
        @context.fillRect xp, yp, xCell+fuzz, yCell+fuzz
    @context.globalAlpha = 1.0
    if @slider?
      val = @viewer.coords_abc[@dim]
      val = (1 - val) unless @dim == Viewer.XAXIS 
      $(@slider.element).slider('option', 'value', val)


  drawCrosshairs: () ->
    ch = @viewSettings.crosshairs
    return unless ch.visible
    @context.fillStyle = ch.color
    xPos = @viewer.coords_abc[[1,0,0][@dim]]*@width
    yPos = (@viewer.coords_abc[[2,2,1][@dim]])*@height
    @context.fillRect 0, yPos - ch.width/2, @width, ch.width
    @context.fillRect xPos - ch.width/2, 0, ch.width, @height


  # Add orientation labels to X/Y/Z slices
  drawLabels: () ->
    return unless @viewSettings.labelsEnabled
    fontSize = Math.round(@height/15)
    @context.fillStyle = 'white'
    @context.font = "#{fontSize}px Helvetica"

    # Show current plane
    @context.textAlign = 'left'
    @context.textBaseline = 'middle'
    planePos = @viewer.coords_xyz()[@dim]
    planePos = '+' + planePos if planePos > 0
    planeText = ['x','y','z'][@dim] + ' = ' + planePos
    @context.fillText(planeText, 0.03*@width, 0.95*@height)

    # Add orientation labels
    @context.textAlign = 'center'
    # @context.textBaseline = 'middle'
    switch @dim
      when 0
        @context.fillText('A', 0.05*@width, 0.5*@height)
        @context.fillText('P', 0.95*@width, 0.5*@height)
      when 1
        @context.fillText('D', 0.95*@width, 0.05*@height)
        @context.fillText('V', 0.95*@width, 0.95*@height)
      when 2
        @context.fillText('L', 0.05*@width, 0.05*@height)
        @context.fillText('R', 0.95*@width, 0.05*@height)


  # Pass through data from a nav slider event to the viewer for position update
  navSlideChange: (value) ->
    value = (1 - value) unless @dim == Viewer.XAXIS
    @viewer.moveToViewerCoords(@dim, value)


  # Kludgy way of applying a grid; in future this should be abstracted
  # away into a ViewSettings class that stores all the dimension/orientation
  # info and returns dynamic transformation methods.
  _snapToGrid: (x, y) ->
    dims = [91, 109, 91]
    dims.splice(@dim, 1)
    xVoxSize = 1 / dims[0]
    yVoxSize = 1 / dims[1]
    # xVoxSize = @xCell
    # yVoxSize = @yCell
    x = (Math.floor(x/xVoxSize) + 0.5)*xVoxSize
    y = (Math.floor(y/yVoxSize) + 0.5)*yVoxSize
    return { x: x, y: y }

      
  _jQueryInit: ->
    canvas = $(@element).find('canvas')
    canvas.click @_canvasClick
    canvas.mousedown((evt) =>
      document.body.style.mozUserSelect = document.body.style.webkitUserSelect = document.body.style.userSelect = "none"
      @lastX = evt.offsetX or (evt.pageX - canvas.offset().left)
      @lastY = evt.offsetY or (evt.pageY - canvas.offset().top)
      @dragStart = @context.transformedPoint(@lastX, @lastY)
    )
    canvas.mousemove((evt) =>
      return unless @viewSettings.panzoomEnabled
      @lastX = evt.offsetX or (evt.pageX - canvas.offset().left)
      @lastY = evt.offsetY or (evt.pageY - canvas.offset().top)
      if @dragStart
        pt = @context.transformedPoint(@lastX, @lastY)
        @context.translate pt.x - @dragStart.x, pt.y - @dragStart.y
        @viewer.paint()
    )
    canvas.mouseup((evt) =>
      @dragStart = null
    )
    canvas.on("DOMMouseScroll", @_handleScroll)
    canvas.on("mousewheel", @_handleScroll)


  _canvasClick: (e) =>
    $(@viewer).trigger('beforeClick')
    clickX = e.offsetX or (e.pageX - $(@element).offset().left)
    clickY = e.offsetY or (e.pageY - $(@element).offset().top)
    pt = @context.transformedPoint(clickX, clickY)
    cx = pt.x / @width
    cy = pt.y / @height
    pt = @_snapToGrid(cx, cy)
    @viewer.moveToViewerCoords(@dim, pt.x, pt.y)
    $(@viewer).trigger('afterClick')


  _zoom: (clicks) =>
    return unless @viewSettings.panzoomEnabled
    pt = @context.transformedPoint(@lastX, @lastY)
    @context.translate pt.x, pt.y
    factor = Math.pow(@scaleFactor, clicks)
    @context.scale factor, factor
    @context.translate -pt.x, -pt.y
    @viewer.paint()


  _handleScroll: (evt) =>
    oe = evt.originalEvent
    delta = (if oe.wheelDelta then (oe.wheelDelta / 40) else (if oe.detail then -oe.detail else 0))
    @_zoom delta  if delta
    evt.preventDefault() and false



class Crosshairs

  constructor: (@visible=true, @color='lime', @width=1) ->



class ColorMap

  # For now, palettes are hard-coded. Should eventually add facility for
  # reading in additional palettes from file and/or creating them in-browser.
  @PALETTES =
    grayscale: ['#000000','#303030','gray','silver','white']
  # Add monochrome palettes
  basic = ['red', 'green', 'blue', 'yellow', 'purple', 'lime', 'aqua', 'navy']
  for col in basic
    @PALETTES[col] = ['black', col, 'white']
  # Add some other palettes
  $.extend(@PALETTES, {
    'intense red-blue': ['#053061', '#2166AC', '#4393C3', '#F7F7F7', '#D6604D', '#B2182B', '#67001F']
    'red-yellow-blue': ['#313695', '#4575B4', '#74ADD1', '#FFFFBF', '#F46D43', '#D73027', '#A50026']
    'brown-teal': ['#003C30', '#01665E', '#35978F', '#F5F5F5', '#BF812D', '#8C510A', '#543005']
  })

  
  constructor: (@min, @max, @palette = 'hot and cold', @steps = 40) ->
    @range = @max - @min
    @colors = @setColors(ColorMap.PALETTES[@palette])


  # Map values to colors. Currently uses a linear mapping;  could add option
  # to use other methods.
  map: (data) ->
    res = []
    for i in [0...data.length]
      res[i] = data[i].map (v) =>
        @colors[Math.floor(((v-@min)/@range) * @steps)]
    return res


  # Takes a set of discrete color names/descriptions and remaps them to
  # a space with @steps different colors.
  setColors: (colors) ->
    rainbow = new Rainbow()
    rainbow.setNumberRange(1, @steps)
    rainbow.setSpectrum.apply(null, colors)
    colors = []
    colors.push rainbow.colourAt(i) for i in [1...@steps]
    return colors.map (c) -> "#" + c



class Component

  constructor: (@container, @name, @element) ->
    $(@element).change((e) =>
      @container.settingsChanged()
    )

  getValue: ->
    $(@element).val()

  setValue: (value) ->
    $(@element).val(value)

  setEnabled: (status) ->
    status = if status then '' else 'disabled'
    $(@element).attr('disabled', status)



# A Slider class--wraps around jQuery-ui slider
class SliderComponent extends Component

  constructor: (@container, @name, @element, @orientation, @min, @max, @value, @step) ->
    @range = if @name.match(/threshold/g) then 'max'
    else if @name.match(/nav/g) then false
    else 'min'
    @_jQueryInit()

  change: (e, ui) =>
    # For nav sliders, trigger coordinate update
    if @name.match(/nav/g)
      @container.navSlideChange(ui.value)
    else
      # For visual settings sliders, trigger general UI update
      @container.settingsChanged(e)
    e.stopPropagation()

  _jQueryInit: ->
    $(@element).slider(
      {
        orientation: @orientation
        range: @range
        min: @min
        max: @max
        step: @step
        slide: @change
        value: @value
      }
    )

  getValue: () ->
    $(@element).slider('value')

  setValue: (value) ->
    $(@element).slider('value', value)
    @textField.setValue(value) if @textField?

  # Set the min and max
  setRange: (@min, @max) ->
    $(@element).slider('option', {min: min, max: max})

  attachTextField: (@textField) ->



class SelectComponent extends Component

  constructor: (@container, @name, @element, options) ->
    $(@element).empty()
    for o in options
      $(@element).append($('<option></option>').text(o).val(o))
    super(@container, @name, @element)



class TextFieldComponent extends Component

  constructor: (@container, @name, @element, @slider = null) ->
    # super(@container, @name, @element)
    # If the field is attached to a slider, add appropriate event handlers.
    if @slider?
      @setValue(@slider.getValue())

      $(@element).change((e) =>
        v = @getValue()
        if $.isNumeric(v)
          if v < @slider.min
            v = @slider.min
          else if v > @slider.max
            v = @slider.max
          @setValue(v)
          @slider.setValue(v)
          @container.settingsChanged(e)
      )
      $(@slider.element).on('slide', (e) =>
        @setValue(@slider.getValue())
        e.stopPropagation()
      )

  # Override default because uneditable fields use text() instead of val()
  setValue: (value) ->
    $(@element).val(value)
    $(@element).text(value)


class DataField

  constructor: (@panel, @name, @element) ->




