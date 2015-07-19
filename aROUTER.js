// Generated by CoffeeScript 1.9.2
(function() {
  var R;

  R = function(options) {
    var add, check, clearSlashes, flush, getFragment, getRoutes, init, navigate, remove, settings, start;
    settings = {
      routes: {},
      modern: false,
      root: '/'
    };
    init = function(options) {
      if (options && options.root) {
        settings.root = '/' + clearSlashes(options.root) + '/';
      }
      return this;
    };
    getRoutes = function() {
      return this.settings.routes;
    };
    getFragment = function() {
      var fragment, match;
      if (settings.modern) {
        fragment = clearSlashes(decodeURI(location.pathname + location.search));
        fragment = fragment.replace(/\?(.*)$/, '');
        if (settings.root !== '/') {
          fragment = fragment.replace(settings.root, '');
        }
      } else {
        match = location.href.match(/#(.*)$/);
        fragment = match ? match[1] : '';
      }
      return clearSlashes(fragment);
    };
    clearSlashes = function(path) {
      return path.toString().replace(/\/$/, '').replace(/^\//, '');
    };
    add = function(regex, callback) {
      var pattern;
      if (typeof regex === 'function') {
        callback = regex;
        regex = '';
      }
      pattern = clearSlashes(regex);
      console.log('Adding route:', pattern);
      settings.routes[pattern] = callback;
      return this;
    };
    remove = function(param) {
      var callback, ref, regex;
      ref = settings.routes;
      for (regex in ref) {
        callback = ref[regex];
        if (callback === param || regex.toString() === param.toString()) {
          settings.routes[regex] = null;
          delete settings.routes[regex];
        }
      }
      return this;
    };
    flush = function() {
      settings.routes = [];
      settings.modern = false;
      settings.root = null;
      return this;
    };
    navigate = function(pth) {
      var path;
      path = pth ? pth : '';
      if (settings.modern) {
        console.log('Navigating using history:', path);
        history.pushState(path, null, settings.root + clearSlashes(path));
        check();
      } else {
        console.log('Navigating using hash:', path);
        window.location.hash = path;
      }
      return this;
    };
    check = function(e) {
      var callback, fragment, match, pattern, ref, regex;
      console.log('gotPop');
      fragment = getFragment();
      console.log('Got fragment:', fragment);
      ref = settings.routes;
      for (pattern in ref) {
        callback = ref[pattern];
        regex = new RegExp(pattern);
        match = fragment.match(regex);
        if (match) {
          console.log(match);
          match.shift();
          callback.apply({}, match);
        }
      }
      return this;
    };
    start = function() {
      console.log('Setting popstate event handler');
      return window.addEventListener('popstate', check);
    };
    init(options);
    return {
      add: add,
      remove: remove,
      flush: flush,
      navigate: navigate,
      start: start,
      routes: getRoutes
    };
  };

  window.Router = function(options) {
    return new R(options);
  };

}).call(this);
