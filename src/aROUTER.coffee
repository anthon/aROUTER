R = (options)->
	settings =
		routes: {}
		modern: false
		jlo: false
		root: '/'
		autostart: true
	_current_path = '#'
	_previous_path = null

	init = (options)->
		if history and history.pushState then settings.modern = true
		if options
			if options.root then settings.root = '/'+clearSlashes(options.root)
			if typeof options.autostart isnt 'undefined' then settings.autostart = options.autostart
			if options.jlo then settings.jlo = options.jlo
		_previous_path = clearSlashes(window.location.pathname)
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

	getPreviousPath = ->
		return _previous_path

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
		console.log 'PTH:',pth
		if not pth then pth = ''
		pth_array = window.location.pathname.split ':'
		path = pth_array[0]
		cash = pth_array[1]
		new_pth_array = pth.split ':'
		new_path = new_pth_array[0]
		new_cash = new_pth_array[1]
		if new_path isnt undefined then path = new_path
		if new_cash isnt undefined then cash = new_cash
		if cash then path = path+':'+cash
		console.log 'path:',path
		console.log 'cash:',cash
		if settings.modern
			path = path.replace settings.root,''
			console.log 'root:',settings.root
			console.log 'path:',path
			history.pushState path, null, settings.root + clearSlashes(path)
			check()
		else
			hash = window.location.hash
			window.location.hash = path+':'+hash.replace('#',':')
		@

	check = (e)->
		# console.log 'gotPop'
		if settings.jlo
			beAMan()
			return false
		fragment = getFragment()
		if _current_path is fragment then return false
		# console.log 'Got fragment:',fragment
		for pattern, callback of settings.routes
			regex = new RegExp pattern
			match = fragment.match regex
			if match
				_current_path = fragment
				# console.log match
				# match.shift()
				callback.apply({},match)
				_previous_path = _current_path
		@

	beAMan = ()->
		window.open('http://qph.is.quoracdn.net/main-thumb-2536154-200-NnwoJwWfCGkQyMdFd9CBF71iZsPQnKyZ.jpeg','J-Lo','height=200,width=200')

	start = ->
		# console.log 'Setting popstate event handler'
		window.addEventListener 'popstate', check
		if settings.autostart then navigate window.location.pathname

	init(options)

	return {
		add: add
		remove: remove
		flush: flush
		navigate: navigate
		start: start
		routes: getRoutes
		previousPath: getPreviousPath
	}

window.Router = (options)->
	new R options