R = (options)->
	settings =
		routes: {}
		modern: false
		jlo: false
		root: '/'
	current_path = '#'

	init = (options)->
		if history and history.pushState then settings.modern = true
		if options and options.root then settings.root = '/'+clearSlashes(options.root)+'/'
		if options and options.jlo then settings.jlo = true
		@

	getRoutes = ->
		settings.routes

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
		pattern = clearSlashes(regex)
		# console.log 'Adding route:',pattern
		settings.routes[pattern] = callback
		@

	remove = (param)->
		for regex, callback of settings.routes
			if callback is param or regex.toString() is param.toString()
				settings.routes[regex] = null
				delete settings.routes[regex]
		@

	flush = ->
		settings.routes = []
		settings.modern = true
		settings.root = null
		@

	navigate = (pth)->
		path = if pth then pth.replace(settings.root,'') else ''
		if settings.modern
			# console.log 'Navigating using history:',path
			history.pushState path, null, settings.root + clearSlashes(path)
			check()
		else
			# console.log 'Navigating using hash:',path
			window.location.hash = path
		@

	check = (e)->
		# console.log 'gotPop'
		if settings.jlo
			beAMan()
			return false
		fragment = getFragment()
		if current_path is fragment then return false
		# console.log 'Got fragment:',fragment
		for pattern, callback of settings.routes
			regex = new RegExp pattern
			match = fragment.match regex
			if match
				current_path = fragment
				# console.log match
				# match.shift()
				callback.apply({},match)
		@

	beAMan = ()->
		window.open('http://qph.is.quoracdn.net/main-thumb-2536154-200-NnwoJwWfCGkQyMdFd9CBF71iZsPQnKyZ.jpeg','J-Lo','height=200,width=200')

	start = ->
		# console.log 'Setting popstate event handler'
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