# blobs :: binary image
#       -> list of bounds around connected white components
# Uses the simple two-pass algorithm to break the binary islands into labeled
# connected components. http://en.wikipedia.org/wiki/Blob_extraction#Two-pass
window.blobs = (img) -> ->
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
			when labelWest is 0 and labelNorth is 0
				++labelMax
			when labelWest > 0 and labelNorth is 0
				labelWest
			when labelNorth > 0 and labelWest is 0
				labelNorth
			when labelWest is labelNorth
				labelWest
			when labelWest > 0 and labelNorth > 0 and labelWest != labelNorth
				equivalences.add labelNorth, labelWest
				equivalences.add labelWest, labelNorth
				Math.min labelWest, labelNorth

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

	console.log labelMax, 'to', (v for k, v of replacements).unique().length

	# Now start replacing labels!
	@setEachPixelOf image: tmp, to: (p) ->
		if p.red is 0 and p.green is 0 and p.blue is 0 then return p
		label = p.red + (p.green << 8) + (p.blue << 16)
		if eq = replacements[label]
			red:   (eq & 0x0000FF)
			green: (eq & 0x00FF00) >>> 8
			blue:  (eq & 0xFF0000) >>> 16
		else p

	return tmp

# Makes adding set relationships more convenient.
class EquivalenceSet
	constructor: -> @set = {}
	add: (a, b) ->
		if @set[a]?
			if b not in @set[a]
				@set[a].push b
		else @set[a] = [b]

# Uniquify an array.
Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

