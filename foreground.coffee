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

