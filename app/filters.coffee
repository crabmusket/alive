# Uses a simple color threshold to determine which pixels are not 'background'.
# In this case, the background is nearly white, so we sort of do an inverted
# threshold.
window.foreground = (bg, img) -> ->
	@forEachPixelOf
		image: img
		do: (pixel) -> gray: (pixel.red < bg.red or pixel.green < bg.green or pixel.blue < bg.blue)

window.threshold = (lvl, img) -> ->
	@forEachPixelOf image: img, do: (p) ->
		gray: (p.red + p.green + p.blue > lvl * 3) * 255

# Use the Sobel operator to find the edges of an image based on first-order
# differential convolution. We use just addition to combine the two passes rather
# than vector distance.
window.edges = (img) -> ->
	vert = @forEachPixelOf image: img, do: filters.convolveWith [
		1,  2,  1
		0,  0,  0
		-1, -2, -1
	]
	horiz = @forEachPixelOf image: img, do: filters.convolveWith [
		1, 0, -1
		2, 0, -2
		1, 0, -1
	]
	@do filters.add [vert, horiz]

# Median blur.
window.median = (img) -> ->
	@forEachPixelOf image: img, do: (pixel) ->
		reds = []
		greens = []
		blues = []
		@forEachNeighborOf pixel, (n) ->
			reds.push n.red
			greens.push n.green
			blues.push n.blue
		reds = sort reds
		greens = sort greens
		blues = sort blues
		red: reds[4], green: greens[4], blue: blues[4]

# dilate :: repetition count
#        -> binary image
#        -> binary image with white areas grown
# We use this to expand the borders of our detected objects beyond what might
# have been detected by the threshold, just in case (and to give a bit of
# smoothness).
window.dilate = (times, img) -> ->
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
window.equalize = (img) -> ->
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
window.greyscale = (img) -> ->
	@forEachPixelOf image: img, do: (pixel) ->
		gray: (pixel.red + pixel.green + pixel.blue) / 3

# Converts a colour image to a greyscale representation of the hue of each pixel.
window.toHue = (img) -> ->
	@forEachPixelOf
		image: img
		do: (p) -> gray: (rgb2hsv p)[0] / 360 * 255

# Based on http://www.javascripter.net/faq/rgb2hsv.htm
rgb2hsv = (p) ->
	r = p.red / 255
	g = p.green / 255
	b = p.blue / 255

	min = Math.min r, Math.min g, b
	max = Math.max r, Math.max g, b

	if min is max
		return [0, 0, min]

	d = if r is min then g-b else (if b is min then r-g else b-r)
	h = if r is min then 3 else (if b is min then 1 else 5)

	return [
		60* (h - d / (max - min))
		(max - min) / max
		max
	]
