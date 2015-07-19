R = (options)->
	settings =
		routes: []
		modern: false
		root: '/'

	init = (options)->
		if history and history.pushState then settings.modern = true
		if options and options.root then settings.root = '/'+clearSlashes(options.root)+'/'
		@

	getRoutes = ->
		@.settings.routes

	getFragment = ->
		if settings.modern
			fragment = clearSlashes(decodeURI(location.pathname + location.search))
			fragment = fragment.replace /\?(.*)$/, ''
			if settings.root isnt '/' then fragment = fragment.replace(settings.root, '')
		else
			match = location.href.match /#(.*)$/
			fragment = if match then match[1] else ''
		clearSlashes fragment

	clearSlashes = (path)->
		path.toString().replace(/\/$/,'').replace(/^\//,'')

	add = (regex,callback)->
		if typeof regex is 'function'
			callback = regex
			regex = ''
		settings.routes.push
			regex: regex
			callback: callback
		@

	remove = (param)->
		for route, index in settings.routes
			if route.callback is param or route.regex.toString() is param.toString()
				settings.routes.splice index, 1
		@

	flush = ->
		settings.routes = []
		settings.modern = false
		settings.root = null
		@

	navigate = (pth)->
		path = if pth then pth else ''
		if settings.modern
			history.pushState null, null, settings.root + clearSlashes(path)
		else
			window.location.hash = path
		@

	onPop = (f)->
		console.log 'gotPop'
		fragment = getFragment()
		for route, index in settings.routes
			match = fragment.match route.regex
			if match
				console.log 'match'
				match.shift()
				route.callback.apply({},match)
		@

	start = ->
		window.addEventListener 'popstate', onPop

	init(options)

	return {
		add: add
		remove: remove
		flush: flush
		navigate: navigate
		start: start
		routes: getRoutes
	}

window.Router = (options)->
	new R options