window.processee.init()

webcam = on

source = "test/painting1.jpg"
destination = "capture"

# Setup stage
# Set the canvas size, turn the webcam and so on.
processee.setup ->
	@canvasSize = width: 640, height: 480
	#@webcam = on
	@loadImage source #@webcamImageName = source

# After setup
processee.once ->
	@makeNewImage
		name: destination
		copy: source

# Click responder
# Toggle between webcam and animation. Launch the image processing stuff when
# we need to.
processee.onClick ->
	webcam = !webcam
	if webcam is off
		@do processImage
	else
		processee.clearObjects()

# Processing step
# Performs all the algorithms that turn the captured image into 
processImage = ->
	# Freeze the webcam frame.
	@copyImage
		from: source
		to: destination
	# Get a binary image of separated foreground elements. We subtract the colour
	# separation from the foreground representation to create borders of background
	# between objects of different colours.
	separated = @do filters.sub [
		# Foreground detection: simply chose objects that are not white!
		fgsep = @do dilate 1, @do equalize @do foreground 200, source
		# Colour separation: convert image to hue representation then find borders.
		colsep = @do edges @do median @do toHue source
	]
	# Extract blobs from the separated image.
	[blobbed, regions] = @do blobs separated
	# Convert regions to objects on the canvas.
	for l, r of @do mergeContained @do rejectRegionsBySize regions
		processee.object new Sprite r

# Frame update
# Render either the stream from the webcam, or the animation if it's ready. Need
# to sort out some sort of progress meter.
processee.everyFrame ->
	if webcam is on
		@drawImage source
	else
		@drawImage destination

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
