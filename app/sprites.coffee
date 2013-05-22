# Represents an object on the canvas.
window.Sprite = class Sprite
	constructor: (@region) ->

	draw: (self) ->
		@at x: self.region.min.x, y: self.region.min.y, -> @drawImage self.sprite
		if window.bounds
			@fillColor = alpha: 0
			@strokeColor = if within self.region, @mouse then green: 255 else red: 255
			@drawRect self.region

	init: (img) -> (self) ->
		r = self.region
		# Copy piece of source image to a new buffer for this sprite to render with.
		self.sprite = @makeNewImage width: r.max.x - r.min.x, height: r.max.y - r.min.y
		@setEachPixelOf image: self.sprite, to: (p) ->
			@getPixel x: p.x + r.min.x, y: p.y + r.min.y, of: img

within = (r, p) -> p.x > r.min.x and p.x < r.max.x and p.y > r.min.y and p.y < r.max.y
