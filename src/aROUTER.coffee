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
		route =
			regex: regex
			callback: callback
		console.log 'Adding route:',route
		settings.routes.push route
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
			console.log 'Navigating using history:',path
			history.pushState path, null, settings.root + clearSlashes(path)
			check()
		else
			console.log 'Navigating using hash:',path
			window.location.hash = path
		@

	check = (e)->
		console.log 'gotPop'
		fragment = getFragment()
		console.log 'Got fragment:',fragment
		for route, index in settings.routes
			match = fragment.match route.regex
			if match
				console.log match
				match.shift()
				route.callback.apply({},match)
		@

	start = ->
		console.log 'Setting popstate event handler'
		window.addEventListener 'popstate', check

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