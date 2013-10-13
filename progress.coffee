class IronRouterProgress
	@prepare : ->
		@element = $ """<div id="iron-router-progress"></div>"""

		# When the transition ends, and we're actually done with the progres, simply reset it
		@element.on 'transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd', (e) =>
			@reset() if @percent >= 100

		$('body').append @element

	@reset : ->
		@percent = 0
		@alive   = false
		if @element
			@element.removeClass 'loading done'
			@element.css 'width', '0%'

			# Hack to reset the CSS transition
			@element[0].offsetWidth = @element[0].offsetWidth

	@start : ->
		return if @alive
		@reset()
		if @element
			@alive = true
			@element.addClass 'loading'
			@progress()

	# Used to add 10% or more to the progress meter
	@progress : (progress = 10) ->
		@percent += progress

		# If the progress is 100% or more, set it to be done
		return @done() if @percent >= 100

		@element.css 'width', "#{@percent}%" if @element

	@done : (progress = 10) ->
		if @element
			# Set width to 100% to indicate we're done loading
			@element.addClass 'done'
			@element.removeClass 'loading'
			@element.css 'width', '100%'

# Our callbacks, we'll be calling on all routes
callbacks =
	before : ->
		IronRouterProgress.progress 40

		# XX: Fix me - When the `notFoundTemplate` is rendered, no more callbacks are made
		# We need to detect, if this is the last event called.
		# I was going to use @stopped, but it's not set yet, but is set in 1ms, if we use setTimeout
		setTimeout =>
			IronRouterProgress.done() if @stopped
		, 1
	after : ->
		IronRouterProgress.done()
	unload : ->
		IronRouterProgress.reset()
	waitOn : ->
		IronRouterProgress.start()
		ready : -> true

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
$ -> IronRouterProgress.prepare()
