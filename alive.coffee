window.processee.init()

webcam = on

# Setup stage
# Set the canvas size, turn the webcam and so on.
processee.setup ->
	@canvasSize = width: 640, height: 480
	#@webcam = on
	#@webcamImageName = "webcam"
	@loadImage "test/painting2.jpg"

# After setup
processee.once ->
	@makeNewImage
		name: "capture"
		#copy: "webcam"
		copy: "test/painting2.jpg"

# Frame update
# Render either the stream from the webcam, or the animation if it's ready. Need
# to sort out some sort of progress meter.
processee.everyFrame ->
	if webcam is on
		#@drawImage "webcam"
		@drawImage "test/painting2.jpg"
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
		from: @do blobs @do dilate 1, @do foreground 200, "test/painting2.jpg"
		#from: @do equalize @do foreground 128, "webcam"
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

threshold = (lvl, img) -> ->
	@forEachPixelOf image: img, do: (p) ->
		gray: (p.red + p.green + p.blue > lvl * 3) * 255

# blobs :: binary image
#       -> list of bounds around connected white components
# Uses the simple two-pass algorithm to break the binary islands into labeled
# connected components. http://en.wikipedia.org/wiki/Blob_extraction#Two-pass
blobs = (img) -> ->
	equivalences = new EquivalenceSet()
	labelMax = 0
	tmp = @copyImage from: img
	@setEachPixelOf image: tmp, inPlace: yes, to: (p) ->
		# Don't consider 0 (background) pixels.
		if p.red is 0 and p.green is 0 and p.blue is 0 then return p

		# Get pixels and their labels (which are just the 24-bit numbers formed by
		# their color channels).
		north = @getPixel x: p.x, y: p.y-1, of: tmp
		west  = @getPixel x: p.x-1, y: p.y, of: tmp
		labelNorth = north.red + (north.green << 8) + (north.blue << 16)
		labelWest  = west.red + (west.green << 8) + (west.blue << 16)

		# Decide which label to take, and whether to mark labels for merging.
		label = switch
			when labelWest > 0
				labelWest
			when labelWest > 0 and labelNorth > 0 and labelWest != labelNorth
				min = Math.min labelWest, labelNorth
				max = Math.max labelWest, labelNorth
				equivalences.add max, min
				min
			when labelNorth > 0
				labelNorth
			else
				++labelMax
				equivalences.add labelMax, labelMax
				labelMax

		# Reconstruct RGB values based on label we decided on.
		labelled =
			red:   (label & 0x0000FF)
			green: (label & 0x00FF00) >>> 8
			blue:  (label & 0xFF0000) >>> 16
	
	# Now construct the equivalency mapping. At the moment, each label has a big
	# list of labels it's equivalent to. We reduce that to a 1-to-1 mapping so we
	# can actually start replacing labels.
	replacements = {}
	for label, eqs of equivalences.set
		replacements[label] = (sort eqs)[0]

	# Now start replacing labels!
	@setEachPixelOf image: tmp, to: (p) ->
		if p.red is 0 and p.green is 0 and p.blue is 0 then return p
		label = p.red + (p.green << 8) + (p.blue << 16)
		eq = replacements[label]
		if eq?
			red:   (eq & 0x0000FF)
			green: (eq & 0x00FF00) >>> 8
			blue:  (eq & 0xFF0000) >>> 16
		else
			console.log 'loner!'
			p

	return tmp

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

class EquivalenceSet
	constructor: -> @set = {}
	add: (a, b) ->
		if @set[a]?
			if b not in @set[a]
				@set[a].push b
		else @set[a] = [b]

# dilate :: repetition count
#        -> binary image
#        -> binary image with white areas grown
# We use this to expand the borders of our detected objects beyond what might
# have been detected by the threshold, just in case (and to give a bit of
# smoothness).
dilate = (times, img) -> ->
	if times <= 0 then return img
	tmp = @copyImage from: img
	for n in [1..times]
		@setEachPixelOf
			image: tmp
			to: (pixel) ->
				if pixel.red > 0 then return pixel
				anyWhites = no
				@forEachNeighborOf pixel, (neigh) ->
					if neigh.red > 0 then anyWhites = yes
				if anyWhites then gray: 1 else pixel
	return tmp

# equalize :: greyscale image
#          -> full output range greyscale image
# Does histogram equalisation on a greyscale image. Taken from example.
equalize = (img) -> ->
  # Determine the lowest and highest grey values.
  min = 255
  max = 0
  @forEachPixelOf image: img, do: (pixel) ->
    min = pixel.red if pixel.red < min
    max = pixel.red if pixel.red > max
  # Scale all pixels from min to max.
  @forEachPixelOf image: img, do: (pixel) ->
    gray: (pixel.red - min) / (max - min) * 255

# greyscale :: colour image -> greyscale image
# Pretty obvious.
greyscale = (img) -> ->
	@forEachPixelOf image: img, do: (pixel) ->
		gray: (pixel.red + pixel.green + pixel.blue) / 3

# edges :: greyscale image
#       -> greyscale edges of image
# Uses the Sobel operator to find the edges of an image based on first-order
# differential convolution.
edges = (img) -> ->
	vert = @forEachPixelOf image: img, do: filters.convolveWith [
		1,  2,  1,
		0,   0,  0,
		-1, -2, -1
	]
	horiz = @forEachPixelOf image: img, do: filters.convolveWith [
		1,  0, -1,
		2, 0, -2,
		1,  0, -1
	]
	@do filters.combine [vert, horiz]

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
