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

