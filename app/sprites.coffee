# Represents an object on the canvas.
window.Sprite = class Sprite
	constructor: (@region) ->
	draw: (self) ->
		@fillColor = alpha: 0
		@strokeColor = if within self.region, @mouse then green: 255 else red: 255
		@drawRect self.region

within = (r, p) -> p.x > r.min.x and p.x < r.max.x and p.y > r.min.y and p.y < r.max.y
