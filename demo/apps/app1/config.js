(function() {
  var config, redis, redisClient, sessionParser, _;

  redis = require('redis');

  redisClient = redis.createClient();

  _ = require('underscore');

  sessionParser = null;

  config = {
    host: 'localhost',
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
    firstMiddleware: {
      mount: '/app1',
      handler: function() {
        return function(req, res, next) {
          console.dir('app1 firstMiddleware');
          return next();
        };
      }
    },
    isProductionMode: process.env.NODE_ENV === 'production',
    route: function() {
      var routeInfos;
      return routeInfos = [
        {
          type: ['get', 'post'],
          route: ['/'],
          template: 'index',
          middleware: [sessionParser],
          handler: function(req, res, cbf, next) {
            return cbf(null, {
              title: '销售单'
            }, {
              'v-ttl': '10s'
            });
          }
        }, {
          route: '/healthchecks',
          handler: function(req, res) {
            return res.end('aaaa');
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
    },
    session: function() {
      return {
        key: 'vicanso',
        secret: 'jenny&tree',
        ttl: 30 * 60,
        client: redisClient,
        complete: function(parser) {
          return sessionParser = parser;
        }
      };
    }
  };

  module.exports = config;

}).call(this);
