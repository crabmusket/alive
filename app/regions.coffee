# Gets rid of any regions which have a dimension over half the canvas size. This
# will get rid of large object clusters that we don't actually want to move, but
# will hopefully allow smaller significant objects some lee-way.
window.rejectOversizeRegions = (regions) -> ->
	{width: w, height: h} = @canvasSize
	result = {}
	for l, r of regions
		if r.max.x - r.min.x < w/2 and r.max.y - r.min.y < h/2
			result[l] = r
	result

