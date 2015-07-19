// Generated by CoffeeScript 1.9.2
(function() {
  var R;

  R = function(options) {
    var add, clearSlashes, flush, getFragment, init, navigate, onPop, remove, settings, start;
    settings = {
      routes: [],
      modern: false,
      root: '/'
    };
    init = function(options) {
      if (options && options.root) {
        settings.root = '/' + clearSlashes(options.root) + '/';
      }
      return this;
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
      if (typeof regex === 'function') {
        callback = regex;
        regex = '';
      }
      settings.routes.push({
        regex: regex,
        callback: callback
      });
      return this;
    };
    remove = function(param) {
      var i, index, len, ref, route;
      ref = settings.routes;
      for (index = i = 0, len = ref.length; i < len; index = ++i) {
        route = ref[index];
        if (route.callback === param || route.regex.toString() === param.toString()) {
          settings.routes.splice(index, 1);
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
        history.pushState(null, null, settings.root + clearSlashes(path));
      } else {
        window.location.hash = path;
      }
      return this;
    };
    onPop = function(f) {
      var fragment, i, index, len, match, ref, route;
      fragment = getFragment();
      ref = settings.routes;
      for (index = i = 0, len = ref.length; i < len; index = ++i) {
        route = ref[index];
        match = fragment.match(route.regex);
        if (match) {
          console.log('match');
          match.shift();
          route.callback.apply({}, match);
        }
      }
      return this;
    };
    start = function() {
      return window.addEventListener('popstate', onPop);
    };
    init(options);
    return {
      add: add,
      remove: remove,
      flush: flush,
      navigate: navigate,
      start: start
    };
  };

  window.Router = function(options) {
    return new R(options);
  };

}).call(this);
