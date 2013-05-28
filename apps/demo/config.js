(function() {
  var config, routeInfos;

  routeInfos = [
    {
      route: ['/', '/demo'],
      jadeView: 'demo/index',
      handler: function(req, res, cbf, next) {
        return cbf(null, {
          title: '销售单'
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
    middleware: {
      mount: 'demo',
      handler: function() {
        return function(req, res, next) {
          req._info = {
            app: 'demo'
          };
          return next();
        };
      }
    },
    route: routeInfos
  };

  module.exports = config;

}).call(this);
