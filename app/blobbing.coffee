# blobs :: binary image
#       -> list of bounds around connected white components
#          and the blobbed image
# Uses the simple two-pass algorithm to break the binary islands into labeled
# connected components. http://en.wikipedia.org/wiki/Blob_extraction#Two-pass
window.blobs = (img) -> ->
	equivalences = new UnionFind()
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
		labelWest  = west.red  + (west.green  << 8) + (west.blue  << 16)

		# Decide which label to take, and whether to mark labels for merging.
		label = switch
			when labelWest is 0 and labelNorth is 0
				equivalences.add ++labelMax
				labelMax
			when labelWest > 0 and labelNorth is 0
				labelWest
			when labelNorth > 0 and labelWest is 0
				labelNorth
			when labelWest is labelNorth
				labelWest
			when labelWest > 0 and labelNorth > 0 and labelWest != labelNorth
				equivalences.merge labelWest, labelNorth
				Math.min labelWest, labelNorth

		# Reconstruct RGB values based on label we decided on.
		labelled =
			red:   (label & 0x0000FF)
			green: (label & 0x00FF00) >>> 8
			blue:  (label & 0xFF0000) >>> 16
	
	regions = {}

	# Now start replacing labels!
	@setEachPixelOf image: tmp, to: (p) ->
		# Again, ignore background pixels.
		if p.red is 0 and p.green is 0 and p.blue is 0 then return p

		# Reconstruct this pixel's label and find the set it should belong to.
		label = p.red + (p.green << 8) + (p.blue << 16)
		eq = equivalences.find label

		# Push out the boundaries of this current label.
		region = regions[eq]
		if region?
			region.min = x: Math.min(p.x, region.min.x), y: Math.min(p.y, region.min.y)
			region.max = x: Math.max(p.x, region.max.x), y: Math.max(p.y, region.max.y)
		else
			# Construct a new region if it wasn't present.
			regions[eq] =
				min: { x: p.x, y: p.y }
				max: { x: p.x, y: p.y }

		# Decompose the new label inro RGB components.
		newlabel =
			red:   (eq & 0x0000FF)
			green: (eq & 0x00FF00) >>> 8
			blue:  (eq & 0xFF0000) >>> 16

	# Entire function returns both the blobbed image and the regions discovered.
	return [tmp, regions]

# Makes adding set relationships more convenient.
class UnionFind
	constructor: -> @sets = []

	# Start a new list (set) containing only the given element.
	add: (a) -> @sets.push [a]

	# Remove the list (set) represented by the the given element.
	remove: (a) -> @sets = @sets.filter (s) -> s[0] != a

	# Return the list (set) with a given element in it.
	setWith: (a) ->
		for s in @sets
			if a in s
				return s
		return undefined

	# Return the representative of the list (set) with a given element in it.
	find: (a) -> if s = @setWith a then s[0] else undefined

	# Merge two lists (sets) that contain the given items. The performance is
	# terrible, this needs like 4 O(n) lookups not to mention list concatenation.
	merge: (a, b) ->
		sa = @setWith a
		sb = @setWith b
		if sa is sb then return
		list = sa.concat sb
		@remove sa[0]
		@remove sb[0]
		@sets.push sort list

