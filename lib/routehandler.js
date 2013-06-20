
/**!
* Copyright(c) 2012 vicanso 墨鱼仔
* MIT Licensed
*/


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
      _.each(routeInfos, function(routeInfo) {
        var handle, middleware, routes;
        handle = function(req, res, next) {
          var debug;
          next = _.once(next);
          debug = !config.isProductionMode;
          return routeInfo.handler(req, res, function(err, viewData, statusCode, headerOptions) {
            var tmp, _ref;
            if (statusCode == null) {
              statusCode = 200;
            }
            if (headerOptions == null) {
              headerOptions = {};
            }
            if (_.isObject(statusCode)) {
              tmp = statusCode;
              headerOptions = statusCode;
              statusCode = tmp;
            }
            if (err) {
              return next(err);
            } else if (viewData) {
              res.status(statusCode);
              if (statusCode > 299 && statusCode < 400) {
                return res.redirect(statusCode, viewData);
              } else if (routeInfo.template) {
                viewData.fileImporter = new FileImporter(routeInfo.staticsHost);
                if ((_ref = viewData.title) == null) {
                  viewData.title = '未定义标题';
                }
                return httpHandler.render(req, res, routeInfo.template, viewData, headerOptions, next);
              } else {
                if (_.isObject(viewData)) {
                  return httpHandler.json(req, res, viewData);
                } else {
                  return httpHandler.response(req, res, viewData);
                }
              }
            } else {
              return res.status(statusCode).json({
                code: 0
              });
            }
          }, next);
        };
        middleware = routeInfo.middleware || [];
        routes = routeInfo.route;
        if (!_.isArray(routes)) {
          routes = [routes];
        }
        return _.each(routes, function(route) {
          var types;
          types = routeInfo.type || 'get';
          if (!_.isArray(types)) {
            types = [types];
          }
          return _.each(types, function(type) {
            var method;
            method = type.toLowerCase();
            return app[method](route, middleware, handle);
          });
        });
      });
      return this;
    }
  };

  module.exports = routeHandler;

}).call(this);
