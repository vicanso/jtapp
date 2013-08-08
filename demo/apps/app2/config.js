(function() {
  var config, _;

  _ = require('underscore');

  config = {
    host: 'ys.jennyou.com',
    express: {
      enable: ["trust proxy"],
      disabled: ["trust proxy"],
      set: {
        'view engine': 'jade',
        views: "" + __dirname + "/views"
      }
    },
    "static": {
      path: "" + __dirname + "/statics",
      mergePath: "" + __dirname + "/statics/temp",
      mergeUrlPrefix: '/temp',
      maxAge: 3000,
      mergeList: [],
      urlPrefix: '/static'
    },
    firstMiddleware: function() {
      return function(req, res, next) {
        console.dir('app2 firstMiddleware');
        return next();
      };
    },
    isProductionMode: process.env.NODE_ENV === 'production',
    route: function() {
      var routeInfos;
      return routeInfos = [
        {
          type: ['get', 'post'],
          route: ['/'],
          template: 'index',
          handler: function(req, res, cbf, next) {
            return cbf(null, {
              title: '销售单'
            });
          }
        }, {
          route: '/data',
          handler: function(req, res, cbf) {
            return cbf(null, {
              name: 'nick'
            });
          }
        }, {
          route: '/error',
          handler: function(req, res, cbf, next) {
            var err;
            err = new Error;
            err.message = '请求数据失败';
            err.code = -1;
            err.status = 500;
            return cbf(err);
          }
        }
      ];
    }
  };

  module.exports = config;

}).call(this);
