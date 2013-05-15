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

webcam = on

processee.setup ->
	@canvasSize = width: 640, height: 480
	@webcam = on
	@webcamImageName = "webcam"

processee.once ->
	@makeNewImage
		name: "capture"
		copy: "webcam"

processee.everyFrame ->
	if webcam is on
		@drawImage "webcam"
	else
		@drawImage "capture"

processee.onClick ->
	webcam = !webcam
	if webcam is off
		@do processImage

processImage = ->
	@copyImage
		from: "webcam"
		to: "capture"

window.processee.run()
