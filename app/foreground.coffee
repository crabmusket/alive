# foreground :: colour image
#            -> background value
#            -> binary image where gray:1 is foreground
# Uses a simple color threshold to determine which pixels are not 'background'.
# In this case, the background is nearly white, so we sort of do an inverted
# threshold. Note that 'binary image' in this case entails 0,0,0 and 1,0,0, not
# 0,0,0 and 255,255,255.
window.foreground = (bg, img) -> ->
	@forEachPixelOf
		image: img
		do: (pixel) -> gray: (pixel.red < bg or pixel.green < bg or pixel.blue < bg)

window.toHue = (img) -> ->
	@forEachPixelOf
		image: img
		do: (p) -> gray: (rgb2hsv p)[0] * 255 / 360

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
