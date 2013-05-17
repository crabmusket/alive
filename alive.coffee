window.processee.init()

webcam = on

processee.setup ->
	@canvasSize = width: 640, height: 480
	@webcam = on
	@webcamImageName = "webcam"

processee.once ->
	@makeNewImage
		name: "capture"
		copy: "webcam"

processee.everyFrame ->
	if webcam is on
		@drawImage "webcam"
	else
		@drawImage "capture"

processee.onClick ->
	webcam = !webcam
	if webcam is off
		@do processImage

processImage = ->
	@copyImage
		from: "webcam"
		to: "capture"

# foreground :: colour image
#            -> background value
#            -> binary image where white is foreground
# Uses a simple color threshold to determine which pixels are not 'background'.
# In this case, the background is nearly white, so we sort of do an inverted
# threshold.
foreground = (bg, image) -> ->
	@forEachPixelOf
		image: image
		do: (pixel) -> gray: (pixel.red < bg or pixel.green < bg or pixel.blue < bg)

# blobs :: binary image
#       -> list of bounds around connected white components
# Uses the simple two-pass algorithm to break the binary islands into labeled
# connected components.
blobs = (image) -> ->
	# 

# dilate :: binary image
#        -> binary image with white areas grown
# We use this to expand the borders of our detected objects beyond what might
# have been detected by the threshold, just in case (and to give a bit of
# smoothness).
dilate = (image) -> ->
	# 

window.processee.run()

$ ->
	win = $ window
	canvas = $ '#processing'

	window.positionOutput = ->

	pageToCanvas = (e, t) ->
		o = canvas.offset()
		return (
			x: e.pageX - o.left
			y: e.pageY - o.top
			type: t
		)

	canvas.mousedown (e) ->
		if window.processingInstance
			window.processingInstance.__mouseEvent (pageToCanvas e, 'click')
	canvas.mousemove (e) ->
		if window.processingInstance
			window.processingInstance.__mouseEvent (pageToCanvas e, 'move')

	($ '.webcam').toggle(false)
