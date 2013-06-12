(function() {
  var config, jtRedis, sessionParser;

  jtRedis = require('jtredis');

  jtRedis.configure({
    query: true,
    redis: {
      name: 'vicanso',
      uri: 'redis://localhost:10010',
      pwd: 'REDIS_PWD'
    }
  });

  sessionParser = function(req, res, next) {
    return next();
  };

  config = {
    firstMiddleware: {
      mount: 'demo',
      handler: function() {
        return function(req, res, next) {
          console.dir('demo firstMiddleware');
          return next();
        };
      }
    },
    route: function() {
      var routeInfos;
      return routeInfos = [
        {
          type: ['get', 'post'],
          route: ['/'],
          template: 'demo/index',
          middleware: [sessionParser],
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
            err = new Error('请求数据失败');
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
        client: jtRedis.getClient('vicanso'),
        complete: function(parser) {
          return sessionParser = parser;
        }
      };
    }
  };

  module.exports = config;

}).call(this);
