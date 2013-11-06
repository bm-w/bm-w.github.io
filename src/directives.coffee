directives = angular.module 'bmwDirectives', []

directives.directive 'bmwHeader', [->
	shouldAnimate = not /firefox/i.test window.navigator?.userAgent

	restrict: 'A'
	link: (scope, element, attributes) ->
		el  = d3.select element[0]

		svg = el.append 'svg:svg'
		(g = svg.append 'svg:g')
			.attr 'transform', "translate(#{(svg[0][0].clientWidth or 640) / 2},240)"

		w = 640
		h = 480
		hw = w / 2
		hh = h / 2
		pw = hw - 20
		ph = hh - 20
		n = 35
		dn = (n - 1) / 2 - 1
		dx = Math.ceil (w + h) / n
		x0 = dx / 2
		xr = dx / 4
		m = 3

		coordinates = for i in [-dn...dn]
			x: i * dx

		LEFT_LINE_ATTRS = 
			'x1': (d) -> d._ldx1 + m * d._ldx2 + Math.max -pw, d.x + x0 - ph
			'y1': (d) -> m * d._ldx2 + Math.max -ph, -d.x - pw - x0
			'x2': (d) -> -d._ldx2 - m * d._ldx1 + Math.min pw, d.x + x0 + ph
			'y2': (d) -> -m * d._ldx1 + Math.min ph, -d.x + pw - x0
		RIGHT_LINE_ATTRS =
			'x1': (d) -> -d._rdx1 - m * d._rdx2 + Math.min pw, d.x  + x0 + ph
			'y1': (d) -> m * d._rdx2 + Math.max -ph, d.x - pw + x0
			'x2': (d) -> d._rdx2 + m * d._rdx1 + Math.max -pw, d.x + x0 - ph
			'y2': (d) -> -m * d._rdx1 + Math.min ph, d.x + pw + x0

		linesSelection = (g
			.selectAll 'line.right')
			.data coordinates
		(((do linesSelection.enter)
			.append 'svg:g')
			.classed 'datum', true)
			.each (d) ->
				d._ldx1 = x0 * do Math.random
				d._ldx2 = x0 * do Math.random
				d._rdx1 = x0 * do Math.random
				d._rdx2 = x0 * do Math.random
			.attr
				'data-x': (d) -> d.x
			.call (datums) ->
				(leftLines = datums.append 'svg:g')
					.classed 'left': true
				(leftLines.append 'svg:line')
					.classed 'shadow', true
				(leftLines.append 'svg:line')
					.classed 'core', true

				(rightLines = datums.append 'svg:g')
					.classed 'right': true
				(rightLines.append 'svg:line')
					.classed 'shadow', true
				(rightLines.append 'svg:line')
					.classed 'core', true

		DURATION = 500

		geometryStarted = false
		GEOMETRY_INTERVAL = 8000
		do updateGeometry = ->
			(((do linesSelection
				.each (d) ->
					d._ldx1 = xr * (-0.5 + do Math.random)
					d._ldx2 = xr * (-0.5 + do Math.random)
					d._rdx1 = xr * (-0.5 + do Math.random)
					d._rdx2 = xr * (-0.5 + do Math.random)
				.transition)
					.duration DURATION)
					.delay if not geometryStarted then 0 else (d, i) ->
						(2000 * i) / n)
					.call (datums) ->
						(datums.selectAll if geometryStarted then '.left line.core' else '.left line')
							.attr LEFT_LINE_ATTRS
						(datums.selectAll if geometryStarted then '.right line.core' else '.right line')
							.attr RIGHT_LINE_ATTRS
		geometryStarted = true
		window.setInterval updateGeometry, GEOMETRY_INTERVAL if shouldAnimate

		COLORS_INTERVAL = 8000
		RED = "#700000"
		BLUE = "#000070"
		window.setTimeout ->
			return
			colorFlag = false
			colorStarted = false
			do updateColors = ->
				colorFlag = not colorFlag
				((do linesSelection.transition)
					.duration DURATION)
					.call (datums) ->
						(datums.selectAll ".left line.shadow")
							.style 'stroke', if colorFlag then RED else BLUE
						(datums.selectAll ".right line.shadow")
							.style 'stroke', if colorFlag then BLUE else RED
				((do el.transition)
					.duration DURATION)
					.style 'background-color', if colorFlag then BLUE else RED

			colorStarted = true
			window.setInterval updateColors, COLORS_INTERVAL if shouldAnimate
		, COLORS_INTERVAL / 2
]