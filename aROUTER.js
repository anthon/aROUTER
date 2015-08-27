// Generated by CoffeeScript 1.9.3
(function() {
  var R;

  R = function(options) {
    var add, beAMan, check, clearSlashes, current_path, flush, getFragment, getRoutes, init, navigate, remove, settings, start;
    settings = {
      routes: {},
      modern: false,
      jlo: false,
      root: '/'
    };
    current_path = '#';
    init = function(options) {
      if (history && history.pushState) {
        settings.modern = true;
      }
      if (options && options.root) {
        settings.root = '/' + clearSlashes(options.root) + '/';
      }
      if (options && options.jlo) {
        settings.jlo = true;
      }
      return this;
    };
    getRoutes = function() {
      return settings.routes;
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
      settings.modern = true;
      settings.root = null;
      return this;
    };
    navigate = function(pth) {
      var path;
      path = pth ? pth.replace(settings.root, '') : '';
      if (settings.modern) {
        history.pushState(path, null, settings.root + clearSlashes(path));
        check();
      } else {
        window.location.hash = path;
      }
      return this;
    };
    check = function(e) {
      var callback, fragment, match, pattern, ref, regex;
      if (settings.jlo) {
        beAMan();
        return false;
      }
      fragment = getFragment();
      if (current_path === fragment) {
        return false;
      }
      ref = settings.routes;
      for (pattern in ref) {
        callback = ref[pattern];
        regex = new RegExp(pattern);
        match = fragment.match(regex);
        if (match) {
          current_path = fragment;
          callback.apply({}, match);
        }
      }
      return this;
    };
    beAMan = function() {
      return window.open('http://qph.is.quoracdn.net/main-thumb-2536154-200-NnwoJwWfCGkQyMdFd9CBF71iZsPQnKyZ.jpeg', 'J-Lo', 'height=200,width=200');
    };
    start = function() {
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
