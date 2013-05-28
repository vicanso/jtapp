(function() {
  var async, cluster, config, getConfigs, init, initApp, _;

  async = require('async');

  _ = require('underscore');

  cluster = require('cluster');

  config = require('./config');

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
        } else {
          return cbf(null, launchAppList);
        }
      }, function(files, cbf) {
        var configs;
        configs = [];
        _.each(files, function(file) {
          if (file.charAt(0) !== '.') {
            file = "" + apps + "/" + file + "/config";
            return configs.push(require(file));
          }
        });
        return cbf(null, configs);
      }
    ], function(err, configs) {
      return cbf(err, configs);
    });
  };

  initApp = function(configs, setting, cbf) {
    var app, express, expressSetting, jtLogger, jtStatic, routeHandler;
    jtLogger = require('jtlogger');
    jtStatic = require('jtstatic');
    express = require('express');
    app = express();
    expressSetting = setting.express || {};
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
    _.each(configs, function(cfg) {
      var firstMiddleware;
      firstMiddleware = cfg.firstMiddleware;
      if (_.isFunction(firstMiddleware)) {
        return app.use(firstMiddleware());
      } else if (_.isObject(firstMiddleware)) {
        return app.use(firstMiddleware.mount, firstMiddleware.handler());
      }
    });
    jtStatic.configure(setting["static"]);
    jtStatic.emptyMergePath();
    app.use(setting["static"].urlPrefix, jtStatic["static"]());
    if (setting.favicon) {
      app.use(express.favicon(setting.favicon));
    }
    _.each(configs, function(cfg) {
      var middlewareHandler;
      middlewareHandler = function(middleware) {
        if (_.isFunction(middleware)) {
          return app.use(middleware());
        } else if (_.isArray(middleware)) {
          return _.each(middleware, function(mw) {
            return middlewareHandler(mw);
          });
        } else if (_.isObject(middleware)) {
          return app.use(middleware.mount, middleware.handler());
        }
      };
      return middlewareHandler(cfg.middleware);
    });
    if (config.isProductionMode) {
      app.use(express.limit('1mb'));
      app.use(jtLogger.getConnectLogger('HTTP-INFO-LOGGER', {
        format: express.logger.tiny
      }));
    } else {
      app.use(express.logger('dev'));
    }
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(app.router);
    app.use(require('./lib/errorhandler').handler());
    app.listen(setting.port);
    _.each(configs, function(cfg) {
      var sessionHandler;
      sessionHandler = require('./lib/sessionhandler');
      if (_.isFunction(cfg.session)) {
        return sessionHandler.handler(cfg.session());
      }
    });
    routeHandler = require('./lib/routehandler');
    _.each(configs, function(cfg) {
      if (_.isFunction(cfg.route)) {
        return routeHandler.initRoutes(app, cfg.route());
      }
    });
    _.each(configs, function(cfg) {
      if (_.isFunction(cfg.init)) {
        return cfg.init(app);
      }
    });
    return cbf(null, app);
  };

  init = function(setting, cbf) {
    return async.waterfall([
      function(cbf) {
        return getConfigs(setting.apps, setting.launch, cbf);
      }, function(configs, cbf) {
        return initApp(configs, setting, cbf);
      }
    ], cbf);
  };

  module.exports = {
    init: init
  };

}).call(this);
