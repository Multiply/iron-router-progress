class IronRouterProgress
	# Internal variables
	@percent : 0
	@isReady : false
	@isDone  : false
	@element : false

	# Options
	@options        : {}
	@currentOptions : {}

	# Set our @options, by extending our old ones - Can be called multiple times
	@configure : (options = {}) ->
		if _.isObject options
			_.extend @options, options
			@currentOptions = _.clone @options
		@

	@prepare : ->
		return if @isReady

		@element = $ if _.isFunction @options.element then @options.element.call @ else @options.element

		# When the transition ends, and we're actually done with the progres, simply reset it
		@element.on 'transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd', (e) =>
			# Only reset, if this is the last transition, and that it's not a psuedo selector, such as `:before` and `:after`
			# Due to the open nature, of the CSS, I want people to be able to do whatever they like, and as such
			# simply expecting opacity to reach zero, or specific propertyName to execute won't suffice
			# A more elegant solution should be added, as not all browsers may support transition-property
			# witout their vendor prefixes
			@reset() if e.originalEvent.pseudoElement is '' and e.originalEvent.propertyName is _.last @element.css('transition-property').split ', '

		@isReady = true
		$('body').append @element
		@

	# Usually called by @start, but can also be called to simply stop the progress
	@reset : ->
		if @isReady
			clearTimeout @ticker
			@percent = 0
			@isDone  = false
			
			@currentOptions.reset.call @
		@

	# Starts a new progress
	@start : (options = {}) ->
		@currentOptions = _.extend {}, @options, options if _.isObject options

		if @isReady
			@reset()
			@progress()
			
			@tick() if @currentOptions.tick
		@

	@tick : ->
		@ticker = setTimeout =>
			@progress()
			@tick()
		, Math.random() * 750 + 750
		@

	# Adds `progress` or a random percent to the progress bar
	@progress : (progress = false) ->
		# XX We need a better random number generation here
		@percent += if progress then progress else (100 - @percent) * (Math.random() * 0.45 + 0.05) | 0

		# If the progress is 100% or more, set it to be done
		return @done() if @percent >= 100

		@currentOptions.progress.call @
		@

	# Completes the progress by setting the progress to 100%
	@done : ->
		if @isReady and not @isDone
			clearTimeout @ticker

			@percent = 100
			@isDone  = true

			@currentOptions.done.call @
		@

# Default options
IronRouterProgress.configure
	element : -> """<div id="iron-router-progress"#{if @options.spinner then ' class="spinner"' else ''}></div>"""
	spinner : true
	tick    : true
	
	# Callbacks
	# Resets the transition
	reset : ->
		@element.removeClass 'loading done'
		@element.css 'width', '0%'

		# Hack to reset the CSS transition
		@element[0].offsetWidth = @element[0].offsetWidth
		@

	progress : ->
		@element.addClass 'loading'
		@element.removeClass 'done'
		@element.css 'width', "#{@percent}%" if @element
		@

	done : ->
		@element.addClass 'done'
		@element.css 'width', '100%'
		@

initialPage = true
action      = false

# Our callbacks, we'll be calling on all routes
callbacks =
	load : ->
		action = 'load'
		# Take the options from the route, if any
		IronRouterProgress.start @options.progress or {}
		@
	before : (pause)->
		action = 'before'
		if @ready()
			IronRouterProgress.done()
		else
			IronRouterProgress.progress()
			if _.isFunction pause
				pause()
			else
				this.stop()
		@
	after : ->
		IronRouterProgress.done()
		@
	unload : ->
		action      = 'unload'
		initialPage = false
		IronRouterProgress.reset()
		@

# Override iron-router's IronRouteController.prototype.stop
# Used for stopping the progress bar from loading endlessly, when calling @stop() inside callbacks
RouteControllerStopOld = RouteController.prototype.stop
RouteController.prototype.stop = ->
	result = RouteControllerStopOld.call @

	IronRouterProgress.done() if action is 'load'

	# Return the original result, if any
	result

# Override iron-router's Router.map and inject our callbacks to all routes
RouterMapOld = Router.map
Router.map = (map) ->
	result = RouterMapOld.call @, map

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

	# Return the original result, if any
	result

# Prepare our DOM-element when jQuery is ready
$ ->
	IronRouterProgress.prepare()
	console.log 'Loaded?'

