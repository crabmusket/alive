window.processee.init()

# Different states of operation we may be in.
stages =
	capture: 0 # Render the captued image (e.g., webcam stream)
	process: 1 # During processing. Not very useful.
	render: 2  # Rendering the reconstructed scene with objects.
stage = stages.capture

# Global variables set by the UI.
window.source = "test/painting1.jpg"
window.bounds = no

# Name of the image we use as a temporary buffer for a single frame.
destination = "capture"

# Set the canvas size, turn on the webcam and load up the test image files.
processee.setup ->
	@loadImage "test/painting#{i}.jpg" for i in [1..3]
	@canvasSize = width: 640, height: 480
	@webcam = on
	@frameRate 30

# After setup, make a new image to hold the captured frame.
processee.once ->
	@makeNewImage
		name: destination
		copy: source

# Click responder toggles between stages. Each stage has some special actions.
processee.onClick ->
	switch stage
		when stages.capture
			# Process the captured image!
			stage = stages.process
			@do processImage
		when stages.render
			# Destroy all the objects ready to restart the capture process.
			stage = stages.capture
			processee.clearObjects()

# Performs all the algorithms that turn the captured image into a series of
# objects.
processImage = ->
	source = window.source
	col = objToColor gray: 200
	# Get a binary image of separated foreground elements. We subtract the colour
	# separation from the foreground representation to create borders of background
	# between objects of different colours.
	separated = @do filters.sub [
		# Foreground detection: simply chose objects that are not white!
		fgsep = @do dilate 1, @do equalize @do foreground col, source
		# Colour separation: convert image to hue representation then find borders.
		colsep = @do edges @do median (col = @do toHue source)
	]
	# Extract blobs from the separated image.
	[blobbed, regions] = @do blobs col, separated
	# Convert regions to objects on the canvas.
	for l, r of @do mergeOverlapping @do mergeContained @do rejectRegionsBySize regions
		processee.object (s = new Sprite r), s.init source
	# Freeze (capture) the webcam frame.
	@copyImage
		from: source
		to: destination
	# Finished with the processing stage!
	stage = stages.render

# Render either the stream from the webcam, or the animation if it's ready. Need
# to sort out some sort of progress meter.
processee.everyFrame ->
	source = window.source
	switch stage
		when stages.capture
			@drawImage source
		when stages.render
			@drawImage destination

window.processee.run()

