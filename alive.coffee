$ ->
	win = $ window
	canvas = $ '#processing'

	window.positionOutput = ->

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

	($ '.webcam').toggle(false)

window.processee.init()

processee.setup ->
	@canvasSize = width: 640, height: 480
	@webcam = on
	@webcamImageName = "webcam"

processee.everyFrame ->
	@drawImage "webcam"

window.processee.run()
