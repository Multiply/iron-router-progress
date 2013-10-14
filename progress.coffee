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
		if @element
			clearTimeout @ticker
			@percent = 100
			@element.addClass 'done'
			@element.css 'width', '100%'

initialPage = true
lastAction  = false

# Our callbacks, we'll be calling on all routes
callbacks =
	before : ->
		IronRouterProgress.progress()

		# XX: Fix me - When the `notFoundTemplate` is rendered, no more callbacks are made
		# We need to detect, if this is the last event called.
		# I was going to use @stopped, but it's not set yet, but is set in 1ms, if we use setTimeout
		setTimeout =>
			IronRouterProgress.done() if @stopped
		, 1
		lastAction = 'before'
	after : ->
		IronRouterProgress.done()
		lastAction = 'after'
	unload : ->
		IronRouterProgress.reset()
		initialPage = false
		lastAction  = 'unload'
	waitOn : ->
		# If the last action was a `waitOn` or we're at the initial page, simply add progress
		if lastAction is 'waiton' or (initialPage and lastAction isnt false)
			IronRouterProgress.progress()
		else
			# Enable ticks by default, and only disable ticks, if they set to true globally, or per route
			IronRouterProgress.start not (Router.options.disableProgressTick or @options.disableProgressTick)
		lastAction = 'waiton'
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
$ -> IronRouterProgress.prepare not Router.options.disableProgressSpinner
