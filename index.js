
/**!
* Copyright(c) 2012 vicanso 墨鱼仔
* MIT Licensed
*/


(function() {
  var JTStatic, async, config, express, getConfigs, init, initApp, initApps, middlewareHandler, _;

  async = require('async');

  _ = require('underscore');

  express = require('express');

  JTStatic = require('jtstatic');

  config = require('./config');

  /**
   * getConfigs 获取配置文件
   * @param  {[type]} apps          [description]
   * @param  {[type]} launchAppList =             'all' [description]
   * @param  {[type]} cbf           [description]
   * @return {[type]}               [description]
  */


  getConfigs = function(apps, launchAppList, cbf) {
    var fs;
    if (launchAppList == null) {
      launchAppList = 'all';
    }
    fs = require('fs');
    return async.waterfall([
      function(cbf) {
        if (launchAppList === 'all') {
          return fs.readdir(apps, cbf);
        } else if (launchAppList === 'one') {
          return cbf(null, apps);
        } else {
          return cbf(null, launchAppList);
        }
      }, function(files, cbf) {
        var configs;
        configs = [];
        if (_.isString(files)) {
          configs.push(require(files));
        } else {
          _.each(files, function(file) {
            if (file.charAt(0) !== '.') {
              if (apps) {
                file = "" + apps + "/" + file + "/config";
              } else {
                file = "" + file + "/config";
              }
              return configs.push(require(file));
            }
          });
        }
        return cbf(null, configs);
      }
    ], cbf);
  };

  middlewareHandler = function(app, middleware) {
    if (_.isFunction(middleware)) {
      return app.use(middleware());
    } else if (_.isArray(middleware)) {
      return _.each(middleware, function(mw) {
        return middlewareHandler(app, mw);
      });
    } else if (_.isObject(middleware)) {
      return app.use(middleware.mount, middleware.handler());
    }
  };

  initApp = function(config, app) {
    var expressSetting, firstMiddleware, jtStatic, routeHandler, sessionHandler, _ref;
    if (app == null) {
      app = express();
    }
    expressSetting = config.express || {};
    if (expressSetting.enable) {
      _.each(expressSetting.enable, function(key) {
        return app.enable(key);
      });
    }
    if (expressSetting.disabled) {
      _.each(expressSetting.disabled, function(key) {
        return app.disabled(key);
      });
    }
    if (expressSetting.set) {
      _.each(expressSetting.set, function(value, key) {
        return app.set(key, value);
      });
    }
    firstMiddleware = config.firstMiddleware;
    if (_.isFunction(firstMiddleware)) {
      app.use(firstMiddleware());
    } else if (_.isObject(firstMiddleware)) {
      app.use(firstMiddleware.mount, firstMiddleware.handler());
    }
    jtStatic = new JTStatic;
    if ((_ref = config["static"]) != null ? _ref.convertExts : void 0) {
      jtStatic.convertExts(config["static"].convertExts);
      delete config["static"].convertExts;
    }
    jtStatic.configure(config["static"]);
    jtStatic.emptyMergePath();
    app.use(config["static"].urlPrefix, jtStatic["static"]());
    if (config.favicon) {
      app.use(express.favicon(config.favicon));
    }
    if (config.middleware) {
      middlewareHandler(app, config.middleware);
    }
    if (config.isProductionMode) {
      app.use(express.limit('1mb'));
      app.use(express.logger('tiny'));
    } else {
      app.use(express.logger('dev'));
    }
    app.use(express.bodyParser({
      keepExtensions: true
    }));
    app.use(express.methodOverride());
    app.use(app.router);
    app.use(require('./lib/errorhandler').handler());
    sessionHandler = require('./lib/sessionhandler');
    if (_.isFunction(config.session)) {
      sessionHandler.handler(config.session());
    }
    routeHandler = require('./lib/routehandler');
    if (_.isFunction(config.route)) {
      routeHandler.initRoutes(app, config.route(), jtStatic);
    }
    if (_.isFunction(config.init)) {
      config.init(app);
    }
    return app;
  };

  initApps = function(configs, port, middleware, cbf) {
    var app;
    app = express();
    if (_.isFunction(middleware)) {
      cbf = middleware;
      middleware = null;
    }
    if (middleware) {
      middlewareHandler(app, middleware);
    }
    _.each(configs, function(cfg) {
      var subApp;
      if (cfg.host) {
        subApp = initApp(cfg);
        if (_.isArray(cfg.host)) {
          return _.each(cfg.host, function(host) {
            return app.use(express.vhost(host, subApp));
          });
        } else {
          return app.use(express.vhost(cfg.host, subApp));
        }
      } else {
        return initApp(cbf, app);
      }
    });
    app.listen(port);
    console.info("server listen on port:" + port);
    return cbf(null, app);
  };

  init = function(setting, cbf) {
    config.maxAge = setting.maxAge;
    return async.waterfall([
      function(cbf) {
        return getConfigs(setting.apps, setting.launch, cbf);
      }, function(configs, cbf) {
        return initApps(configs, setting.port, setting.middleware, cbf);
      }
    ], cbf);
  };

  module.exports = {
    init: init
  };

}).call(this);
