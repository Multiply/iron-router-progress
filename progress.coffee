class IronRouterProgress
	@prepare : (spinner = false) ->
		@element = $ """<div id="iron-router-progress"#{if spinner then ' class="spinner"' else ''}></div>"""

		# When the transition ends, and we're actually done with the progres, simply reset it
		@element.on 'transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd', (e) =>
			# Only reset, if this is the last transition, and that it's not a psuedo selector, such as `:before` and `:after`
			# Due to the open nature, of the CSS, I want people to be able to do whatever they like, and as such
			# simply expecting opacity to reach zero, or specific propertyName to execute won't suffice
			# A more elegant solution should be added, as not all browsers may support transition-property
			# witout their vendor prefixes
			@reset() if e.originalEvent.pseudoElement is '' and e.originalEvent.propertyName is _.last @element.css('transition-property').split ', '

		$('body').append @element

	# Resets the transition - Usually called by @start, but can also be called to simply stop the progress
	@reset : ->
		clearTimeout @ticker
		@percent = 0
		if @element
			@element.removeClass 'loading done'
			@element.css 'width', '0%'

			# Hack to reset the CSS transition
			@element[0].offsetWidth = @element[0].offsetWidth

	# Starts a new progress
	# If tick is enabled, it will make fake ticks, every 0.75-1.5 seconds
	@start : (tick = false) ->
		if @element
			@reset()
			@progress()
			
			@tick() if tick

	@tick : ->
		@ticker = setTimeout =>
			@progress()
			@tick()
		, Math.random() * 750 + 750

	# Adds `progress` or a random percent to the progress bar
	@progress : (progress = false) ->
		# XX We need a better random number generation here
		@percent += if progress then progress else (100 - @percent) * (Math.random() * 0.45 + 0.05) | 0

		# If the progress is 100% or more, set it to be done
		return @done() if @percent >= 100

		@element.addClass 'loading'
		@element.removeClass 'done'
		@element.css 'width', "#{@percent}%" if @element

	# Completes the progress by setting the progress to 100%
	@done : ->
		if @element and not @element.hasClass 'done'
			clearTimeout @ticker
			@percent = 100
			@element.addClass 'done'
			@element.css 'width', '100%'

initialPage = true
action      = false

# Our callbacks, we'll be calling on all routes
callbacks =
	load : ->
		action = 'load'
		IronRouterProgress.start not (Router.options.disableProgressTick or @options.disableProgressTick)
	before : ->
		action = 'before'
		@wait ->
			# XX Fix me - Should we be done here, or only call it in the `after` hook?
			# If we don't call `done` here, we can use the global hooks, rather than adding them with the hack below
			IronRouterProgress.done()
		, ->
			IronRouterProgress.progress()
			@stop()
	after : ->
		IronRouterProgress.done()
	unload : ->
		action      = 'unload'
		initialPage = false
		IronRouterProgress.reset()

# Override iron-router's IronRouteController.prototype.stop
# Used for stopping the progress bar from loading endlessly, when calling @stop() inside callbacks
RouteControllerStopOld = RouteController.prototype.stop
RouteController.prototype.stop = ->
	RouteControllerStopOld.call @

	IronRouterProgress.done() if action is 'load'

# Override iron-router's Router.map and inject our callbacks to all routes
RouterMapOld = Router.map
Router.map = (map) ->
	RouterMapOld.call @, map

	for route in @routes
		# If progress is disabled for this route, simply continue
		continue if route.options.disableProgress
		for type, cb of callbacks
			if _.isArray route.options[type]
				route.options[type].push cb
			else if _.isFunction route.options[type]
				route.options[type] = [route.options[type], cb]
			else
				route.options[type] = cb

# Prepare our DOM-element when jQuery is ready
$ -> IronRouterProgress.prepare not Router.options.disableProgressSpinner
