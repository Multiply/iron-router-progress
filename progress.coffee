class IronRouterProgress
	@count : 0
	@prepare : ->
		@element = $ """<div id="iron-router-progress"></div>"""
		$('body').append @element

	@reset : ->
		@percent = 0
		@alive   = false
		if @element
			@element.removeClass 'loading done'
			@element.css 'width', '0%'
		++@count

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
		count = @count
		if @element
			setTimeout =>
				# Set width to 100% to indicate we're done loading
				@element.removeClass 'loading'
				@element.addClass 'done'
				@element.css 'width', '100%'
	
				@alive = false
				setTimeout =>
					# Count each load, so our end timeout won't be called multiple times, when it's loading something else
					return if count isnt @count
					@reset()
				, 1000 * (Router.options.progressSpeed or 1.5)
			, 1

# Our callbacks, we'll be calling on all routes
callbacks =
	before : ->
		console.log 'before'
		IronRouterProgress.progress 40
	after : ->
		console.log 'after'
		IronRouterProgress.done()
	unload : ->
		console.log 'unload'
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
