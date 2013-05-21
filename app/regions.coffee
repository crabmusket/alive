# Gets rid of any regions which have a dimension over half the canvas size or
# the total area is small. This will get rid of large object clusters that we
# don't actually want to move, but will hopefully allow smaller significant
# objects some lee-way.
window.rejectRegionsBySize = (regions) -> ->
	{width: w, height: h} = @canvasSize
	result = {}
	for l, r of regions
		rw = r.max.x - r.min.x
		rh = r.max.y - r.min.y
		if rw > w/2 or rh > h/2 then continue
		if (area r) < 100 then continue
		result[l] = r
	result

# Merge regions that are entirely inside other regions. Don't really want them
# to stick around as separate entities... deciding when to do that or not would
# be incresibly difficult! So we just assume we'll always merge.
window.mergeContained = (regions) -> ->
	for l1, r1 of regions
		for l2, r2 of regions
			if l1 is l2 then continue
			if contains r2, r1
				delete regions[l2]
	regions

# Merge regions that are overlapping. Only merge regions where the larger one is
# overlapping at least 40% of the smaller one's area. This stops large regions
# from taking over the world by touching tons of AABBs.
window.mergeOverlapping = (regions) -> ->
	changed = yes
	while changed
		changed = no
		for l1, r1 of regions
			for l2, r2 of regions
				if l1 is l2 then continue
				if intersecting r1, r2
					a1 = area r1
					a2 = area r2
					am = Math.min a1, a2
					lap = area overlap r1, r2
					if lap > 0.4 * Math.min a1, a2
						changed = yes
						r1.min.x = Math.min r1.min.x, r2.min.x
						r1.min.y = Math.min r1.min.y, r2.min.y
						r1.max.x = Math.max r1.max.x, r2.max.x
						r1.max.y = Math.max r1.max.y, r2.max.y
						delete regions[l2]
	regions

# Does r1 contain r2?
contains = (r2, r1) -> r1.min.x < r2.min.x and r1.max.x > r2.max.x and r1.min.y < r2.min.y and r1.max.y > r2.max.y

# Do two regions intersect?
intersecting = (r1, r2) ->
	if r1.max.x < r2.min.x then return no
	if r1.min.x > r2.max.x then return no
	if r1.max.y < r2.min.y then return no
	if r1.min.y > r2.min.y then return no
	yes

# Get intersection box of regions.
overlap = (r1, r2) ->
	min:
		x: Math.max r1.min.x, r2.min.x
		y: Math.max r1.min.y, r2.min.y
	max:
		x: Math.min r1.max.x, r2.max.x
		y: Math.min r1.max.y, r2.max.y

# Get area of region.
area = (r) -> (r.max.x - r.min.x) * (r.max.y - r.min.y)
