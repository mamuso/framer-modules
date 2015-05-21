## ------------------------------------------------------------------------------------------
# Circular spinner with snapsvg
# Bits and pieces borowed from http://share.framerjs.com/195308v9yp1w/
## ------------------------------------------------------------------------------------------

# You need to include the snapsvg.io library into your index.html
# https://raw.githubusercontent.com/adobe-webplatform/Snap.svg/master/dist/snap.svg-min.js
## <script src="js/snap.svg-min.js"></script>

# Add the following line to your project in Framer Studio. 
## cs = require "circularSpinner"

# Then draw the spinner calling. 
## cs.new(_width, _height, _strokewidth)

# By defaut, the spinner is centered in the screen, you can position it accessing
## cs._canvas


# Defaults
_id = Date.now()
_defaultwidth = 150
_defaultheight = 150
_strokewidth = 20
_cbase = "#FFFFFF"
_cspinner = "#0268B2"
_cspeed = 3
_radius = null
_arc = null
_snap = null
_i = 0

# Module level variable, so we can position it afterwards
exports._canvas = new Layer
  backgroundColor: "none"
_canvas = exports._canvas # shortcut

exports.new = (_width, _height, _stroke, _colorbase, _colorspinner, _speed) ->

  _canvas.width = _width || _defaultwidth
  _canvas.height = _height || _defaultheight
  _canvas.center()
  _canvas.html = "<svg id='svg#{_id}' style='width:#{_canvas.width}px; height:#{_canvas.height}px; ignore-events:all;'></svg>"

  # snapsvg selector and rest of the variables
  _snap = Snap(_canvas.querySelector("#svg#{_id}"))

  _stroke = _stroke || _strokewidth
  _colorbase = _colorbase || _cbase
  _colorspinner = _colorspinner || _cspinner
  _tempcolor = _colorspinner
  _speed = _speed || _cspeed
  
  # calculate radius
  _radius = (_canvas.width/2) - _stroke

  # draw base
  base = _snap.circle(_canvas.width/2, _canvas.height/2, _radius)
  base.attr
    fill: "none"
    stroke: _colorbase
    strokeWidth: "#{_stroke}px"

  # animation controller
  controller = new Layer { width: 10, height: 10, backgroundColor: "none" }
  controller.states.add { full: x: 100 }
  controller.states.animationOptions = curve: "cubic-bezier(.85,0,.3,.85)", time: _speed 
  controller.on "change:x", (e) ->
    # find new angle
    newAngle = Utils.modulate(e, [0,100], [0,359], true)
    # let's draw!
    drawAngle(newAngle, _tempcolor, _stroke)
    # reverse
    if e == 100
      controller.x = 0
      _i = _i+1
      if _i%2 == 0
        _tempcolor = _colorspinner
        base.attr
          stroke: _colorbase
      else
        _tempcolor = _colorbase
        base.attr
          stroke: _colorspinner

      controller.states.next(["full"])

  # kickoff initial animation
  controller.states.next(["full"])
  _canvas.animate
    properties:
      rotation: (360)
    time: _speed
    curve: "linear"
    repeat: 1000

exports.kill = ->
  _canvas.destroy()



# Draw the angle
drawAngle = (angle, color, stroke) ->
  d = angle
  dr = angle-90 # make 0 degree begin at the top
  radians = Math.PI*(dr)/180 # convert angle to radians
  startx = _canvas.width/2
  starty = _canvas.height/2 - _radius
  endx = _canvas.width/2 + _radius*Math.cos(radians)
  endy = _canvas.height/2 + _radius*Math.sin(radians)
  largeArc = 0; largeArc = 1 if d>180

  # remove arc if it already exists
  _arc?.remove()

  # create arc using SVG path commands
  _arc = _snap.path("
        M#{startx},#{starty} # moveTo top of canvas
        # A rx ry x-axis-rotation large-arc-flag sweep-flag x y
        A#{_radius},#{_radius} 0 #{largeArc},1 #{endx},#{endy} # arc to
      ")
      
  # set attributes of SVG path
  _arc.attr
    fill: "none"
    stroke: "#{color}"
    strokeWidth: "#{stroke}px"
    # strokeLinecap: "round"

