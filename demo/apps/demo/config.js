(function() {
  var config, jtRedis, sessionParser;

  jtRedis = require('jtredis');

  jtRedis.configure({
    query: true,
    redis: {
      name: 'vicanso',
      uri: 'redis://localhost:10010',
      pwd: 'MY_REDIS_JENNY_TREE'
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
          route: ['/'],
          jadeView: 'demo/index',
          middleware: [sessionParser],
          handler: function(req, res, cbf, next) {
            console.dir(req.session);
            return cbf(null, {
              title: '销售单'
            });
          }
        }, {
          route: '/error',
          handler: function(req, res, cbf, next) {
            return cbf(null, {
              name: 'nick'
            });
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
