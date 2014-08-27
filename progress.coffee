class IronRouterProgress
	# Internal variables
	@percent : 0
	@isReady : false
	@isDone  : false
	@element : false
	@delay   : false

	# Options
	@options        : {}
	@currentOptions : {}

	# Set our @options, by extending our old ones - Can be called multiple times
	@configure : (options = {}) ->
		console.log 'configure'
		if _.isObject options
			_.extend @options, options
			@currentOptions = _.clone @options
		@

	@prepare : ->
		console.log 'prepare'
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
		console.log 'reset'
		if @isReady
			clearTimeout @ticker
			clearTimeout @delay
			@percent = 0
			@isDone  = false
			
			@currentOptions.reset.call @
		@

	# Starts a new progress
	@start : (options = {}) ->
		console.log 'start'
		@currentOptions = _.extend {}, @options, options if _.isObject options

		if @isReady
			@reset()
			if @currentOptions.enabled
				# If we have a delay set, wait with running _start
				if @currentOptions.delay and @currentOptions.delay > 0
					@delay = setTimeout =>
						@_start()
					, @currentOptions.delay
				else
					@_start()
		@

	@_start : ->
		console.log '_start'
		@delay = false
		@progress()

		@tick() if @currentOptions.tick

	@tick : ->
		console.log 'tick'
		@ticker = setTimeout =>
			@progress()
			@tick()
		, Math.random() * 750 + 750
		@

	# Adds `progress` or a random percent to the progress bar
	@progress : (progress = false) ->
		# Don't tick, if we're not enabled, or there's an active delay
		return @ if not @currentOptions.enabled

		# XX We need a better random number generation here
		@percent += if progress then progress else (100 - @percent) * (Math.random() * 0.45 + 0.05) | 0

		# If we have a delay, simply return past this point
		return if @delay

		# If the progress is 100% or more, set it to be done
		return @done() if @percent >= 100

		@currentOptions.progress.call @
		@

	# Completes the progress by setting the progress to 100%
	@done : ->
		console.log 'done'
		if @delay
			clearTimeout @delay
			@delay = false

		if @isReady and not @isDone
			clearTimeout @ticker

			@percent = 100
			@isDone  = true

			@currentOptions.done.call @
		@

# Default options
IronRouterProgress.configure
	element : """<div id="iron-router-progress"></div>"""
	spinner : true
	tick    : true
	enabled : true
	delay   : false

	# Callbacks
	# Resets the transition
	reset : ->
		@element.removeClass 'loading done'
		@element.css 'width', '0%'
		@element.toggleClass 'spinner', @currentOptions.spinner

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

Router.onRun ->
	# Take the options from the route, if any
	IronRouterProgress.start @route.options?.progress or {}
	@

Router.onBeforeAction (pause) ->
	if @ready()
		IronRouterProgress.done()
	else
		IronRouterProgress.progress()

		# XX Temporary fix, when you want to show your loading template
		loadingTemplate = @lookupProperty 'loadingTemplate'
		if loadingTemplate
			@render loadingTemplate
			@renderRegions()

		pause()
	@

Router.onAfterAction ->
	IronRouterProgress.done()
	@

Router.onStop ->
	IronRouterProgress.reset()
	@

# Prepare our DOM-element when jQuery is ready
$ -> IronRouterProgress.prepare()
