($ document).ready ->
	win = $ window
	canvas = $ '#processing'

	pageToCanvas = (e, t) ->
		o = canvas.offset()
		return (
			x: e.pageX - o.left
			y: e.pageY - o.top
			type: t
		)

	canvas.mousedown (e) ->
		if window.processingInstance
			window.processingInstance.__mouseEvent (pageToCanvas e, 'click')
	canvas.mousemove (e) ->
		if window.processingInstance
			window.processingInstance.__mouseEvent (pageToCanvas e, 'move')
	
	($ 'form input[type=radio]').change ->
		el = ($ 'form input[type=radio]:checked')
		window.source = el.val()

	($ 'form #bounds').change ->
		el = ($ 'form #bounds')
		window.bounds = el.is ':checked'

	($ '.webcam').toggle(false)

