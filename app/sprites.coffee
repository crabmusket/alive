# Represents an object on the canvas.
window.Sprite = class Sprite
	# Constructor. In this method, `this` refers to the object itself, so the `@`
	# syntax does not call processee functions.
	constructor: (@region) ->
		@mouseOver = no
		@timer = 0
		@animation = @pickAnimation()

	# Draw routine called every frame by Processee.
	draw: (self) ->
		if within self.region, @mouse
			if not self.mouseOver
				# Rising edge! Do stuff when the mouse first enters the shape.
				if self.timer is 0
					self.animation = self.pickAnimation()
				self.timer = 1
			self.mouseOver = yes
		else
			# Nothing to do on a falling edge.
			self.mouseOver = no

		# Animate!
		time = self.timer / 30
		anim = self.animation time

		# Actually render the sprite and bounding rectangle. Translate, rotate and
		# scale the context first.
		@at (centre self.region), ->
			@rotatedBy anim.angle, ->
				@zoom = anim.scale ? 1
				@drawImage self.sprite, center: yes
				if window.bounds
					@fillColor = alpha: 0
					@strokeColor = if self.mouseOver then green: 255 else red: 255
					r = self.region
					@drawRect
						width: r.max.x - r.min.x
						height: r.max.y - r.min.y

		# Stop or update the timer depending on the animation.
		if anim.stop then self.timer = 0
		if self.timer > 0
			self.timer++

	# Initialise this sprite with data from an image.
	init: (img) -> (self) ->
		r = self.region
		# Copy piece of source image to a new buffer for this sprite to render with.
		self.sprite = @makeNewImage width: r.max.x - r.min.x, height: r.max.y - r.min.y
		@setEachPixelOf image: self.sprite, to: (p) ->
			@getPixel x: p.x + r.min.x, y: p.y + r.min.y, of: img
	
	# Select a random animation function.
	pickAnimation: -> animations[Math.floor Math.random() * animations.length]

# List of animation functions we might choose to use.
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

