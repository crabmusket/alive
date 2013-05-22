# Represents an object on the canvas.
window.Sprite = class Sprite
	constructor: (@region) ->
		@mouseOver = no
		@timer = 0
		@animation = @pickAnimation()

	draw: (self) ->
		if within self.region, @mouse
			if not self.mouseOver
				if self.timer is 0
					self.animation = self.pickAnimation()
				self.timer = 1
			self.mouseOver = yes
		else
			self.mouseOver = no

		time = self.timer / 30
		anim = self.animation time

		@at (centre self.region), ->
			@rotatedBy anim.angle, ->
				@zoom = firstDefined [anim.scale, 1]
				@drawImage self.sprite, center: yes
				if window.bounds
					@fillColor = alpha: 0
					@strokeColor = if within self.region, @mouse then green: 255 else red: 255
					r = self.region
					@drawRect
						width: r.max.x - r.min.x
						height: r.max.y - r.min.y

		if anim.stop then self.timer = 0
		if self.timer > 0
			self.timer++

	init: (img) -> (self) ->
		r = self.region
		# Copy piece of source image to a new buffer for this sprite to render with.
		self.sprite = @makeNewImage width: r.max.x - r.min.x, height: r.max.y - r.min.y
		@setEachPixelOf image: self.sprite, to: (p) ->
			@getPixel x: p.x + r.min.x, y: p.y + r.min.y, of: img
	
	pickAnimation: -> animations[Math.floor Math.random() * animations.length]

animations = [
	(t) ->
		angle: 0.1 * (Math.exp -2 * t) * Math.sin 15 * t
		stop: t > 3
	(t) ->
		scale: 1 + 0.1 * (Math.exp -2 * t) * Math.sin 30 * t
		stop: t > 3
]

# Is a point p within a region r?
within = (r, p) -> p.x > r.min.x and p.x < r.max.x and p.y > r.min.y and p.y < r.max.y

# Get centre of a region.
centre = (r) -> x: r.min.x + (r.max.x - r.min.x) / 2, y: r.min.y + (r.max.y - r.min.y) / 2
