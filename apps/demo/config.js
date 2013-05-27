(function() {
  var config, routeInfos;

  routeInfos = [
    {
      route: ['/'],
      jadeView: 'demo/index',
      handler: function(req, res, cbf, next) {
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
    route: routeInfos
  };

  module.exports = config;

}).call(this);
