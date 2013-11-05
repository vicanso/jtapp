/**!
* Copyright(c) 2012 vicanso 墨鱼仔
* MIT Licensed
*/


(function() {
  var config, httpHandler, routeHandler, _;

  _ = require('underscore');

  config = require('../config');

  httpHandler = require('./httphandler');

  routeHandler = {
    /**
     * initRoutes 初始化路由处理
     * @param  {express对象} app   express的实例
     * @param  {Array} routeInfos  路由配置的信息列表
     * @return {[type]}  [description]
    */

    initRoutes: function(app, routeInfos, jtStatic) {
      _.each(routeInfos, function(routeInfo) {
        var handle, middleware, routes;
        handle = function(req, res, next) {
          var cbf;
          next = _.once(next);
          cbf = function(err, renderData, statusCode, headerOptions) {
            var template, tmp;
            if (statusCode == null) {
              statusCode = 200;
            }
            if (headerOptions == null) {
              headerOptions = {};
            }
            if (err) {
              next(err);
              return;
            }
            if (_.isNumber(renderData)) {
              tmp = statusCode;
              statusCode = renderData;
              renderData = tmp;
            }
            if (_.isObject(statusCode)) {
              tmp = statusCode;
              headerOptions = statusCode;
              statusCode = tmp;
            }
            if (!_.isNumber(statusCode)) {
              statusCode = 200;
            }
            if (renderData) {
              template = renderData.template || routeInfo.template;
              res.status(statusCode);
              if (statusCode > 299 && statusCode < 400) {
                return res.redirect(statusCode, renderData);
              } else if (template) {
                renderData.fileImporter = jtStatic.getFileImporter(routeInfo.staticsHost);
                return httpHandler.render(req, res, template, renderData, headerOptions, next);
              } else {
                if (_.isObject(renderData)) {
                  return httpHandler.json(req, res, renderData, headerOptions, next);
                } else {
                  return httpHandler.response(req, res, renderData, headerOptions, next);
                }
              }
            } else {
              return res.status(statusCode).json({
                code: 0
              });
            }
          };
          return routeInfo.handler(req, res, cbf, next);
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

  module.exports.initRoutes = routeHandler.initRoutes;

}).call(this);
