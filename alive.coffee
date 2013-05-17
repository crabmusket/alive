window.processee.init()

webcam = on

# Setup stage
# Set the canvas size, turn the webcam and so on.
processee.setup ->
	@canvasSize = width: 640, height: 480
	@webcam = on
	@webcamImageName = "webcam"

# After setup
processee.once ->
	@makeNewImage
		name: "capture"
		copy: "webcam"

# Frame update
# Render either the stream from the webcam, or the animation if it's ready. Need
# to sort out some sort of progress meter.
processee.everyFrame ->
	if webcam is on
		@drawImage "webcam"
	else
		@drawImage "capture"

# Click responder
# Toggle between webcam and animation. Launch the image processing stuff when
# we need to.
processee.onClick ->
	webcam = !webcam
	if webcam is off
		@do processImage

# Processing step
# Performs all the algorithms that turn the captured image into 
processImage = ->
	@copyImage
		from: @do equalize @do foreground 128, "webcam"
		to: "capture"

# foreground :: colour image
#            -> background value
#            -> binary image where gray:1 is foreground
# Uses a simple color threshold to determine which pixels are not 'background'.
# In this case, the background is nearly white, so we sort of do an inverted
# threshold. Note that 'binary image' in this case entails 0,0,0 and 1,0,0, not
# 0,0,0 and 255,255,255.
foreground = (bg, image) -> ->
	@forEachPixelOf
		image: image
		do: (pixel) -> gray: (pixel.red < bg or pixel.green < bg or pixel.blue < bg)

oldForeground = ->
	@changeEachPixelOf
		image: "capture"
		to: (pixel) ->
			grey = (pixel.red + pixel.green + pixel.blue) / 3
			dev = 0
			dev += Math.abs(pixel.red - grey)
			dev += Math.abs(pixel.green - grey)
			dev += Math.abs(pixel.blue - grey)
			#dev /= 3
			gray: dev

# blobs :: binary image
#       -> list of bounds around connected white components
# Uses the simple two-pass algorithm to break the binary islands into labeled
# connected components.
blobs = (image) -> ->
	# 

# dilate :: repetition count
#        -> binary image
#        -> binary image with white areas grown
# We use this to expand the borders of our detected objects beyond what might
# have been detected by the threshold, just in case (and to give a bit of
# smoothness).
dilate = (times, img) -> ->
	if times <= 0 then return img
	for n in [1..times]
		@setEachPixelOf
			image: img
			to: (pixel) ->
				if pixel.red > 250 then return pixel
				anyWhites = no
				@forEachNeighborOf pixel, (neigh) ->
					if neigh.red > 250 then anyWhites = yes
				if anyWhites then gray: 255 else pixel
	return img

window.processee.run()

($ document).ready ->
	win = $ window
	canvas = $ '#processing'

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
