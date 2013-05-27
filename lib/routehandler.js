(function() {
  var FileImporter, config, httpHandler, routeHandler, _;

  _ = require('underscore');

  config = require('../config');

  FileImporter = require('jtstatic').FileImporter;

  httpHandler = require('./httphandler');

  routeHandler = {
    /**
     * initRoutes 初始化路由处理
     * @param  {express对象} app   express的实例
     * @param  {Array} routeInfos  路由配置的信息列表
     * @return {[type]}  [description]
    */

    initRoutes: function(app, routeInfos) {
      return _.each(routeInfos, function(routeInfo) {
        var handle, middleware, routes;
        handle = function(req, res, next) {
          var debug;
          next = _.once(next);
          debug = !config.isProductionMode;
          return routeInfo.handler(req, res, function(err, viewData, statusCode, headerOptions) {
            var _ref;
            if (statusCode == null) {
              statusCode = 200;
            }
            if (headerOptions == null) {
              headerOptions = {};
            }
            if (err) {
              return next(err);
            } else if (viewData) {
              res.status(statusCode);
              if (statusCode > 299 && statusCode < 400) {
                return res.redirect(statusCode, viewData);
              } else if (routeInfo.jadeView) {
                viewData.fileImporter = new FileImporter(debug, routeInfo.staticsHost);
                if ((_ref = viewData.title) == null) {
                  viewData.title = '未定义标题';
                }
                return httpHandler.render(req, res, routeInfo.jadeView, viewData, headerOptions, next);
              } else {
                if (_.isObject(viewData)) {
                  return httpHandler.json(req, res, viewData);
                } else {
                  return httpHandler.response(req, res, viewData);
                }
              }
            } else {
              err = new Error("" + __filename + ": the viewData is null");
              err.code = 500;
              return next(err);
            }
          }, next);
        };
        middleware = routeInfo.middleware || [];
        routes = routeInfo.route;
        if (!_.isArray(routes)) {
          routes = [routes];
        }
        return _.each(routes, function(route) {
          var method;
          method = (routeInfo.type || 'get').toLowerCase();
          return app[method](route, middleware, handle);
        });
      });
    }
  };

  module.exports = routeHandler;

}).call(this);
