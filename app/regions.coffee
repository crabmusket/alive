# Gets rid of any regions which have a dimension over half the canvas size or
# both dimensions below 5px. This will get rid of large object clusters that we
# don't actually want to move, but will hopefully allow smaller significant
# objects some lee-way.
window.rejectRegionsBySize = (regions) -> ->
	{width: w, height: h} = @canvasSize
	result = {}
	for l, r of regions
		rw = r.max.x - r.min.x
		rh = r.max.y - r.min.y
		if rw > w/2 or rh > h/2 then continue
		if rw < 5 and rh < 5 then continue
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

# Does r1 contain r2?
contains = (r2, r1) -> r1.min.x < r2.min.x and r1.max.x > r2.max.x and r1.min.y < r2.min.y and r1.max.y > r2.max.y
