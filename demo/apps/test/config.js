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
    }
  ];

  config = {
    firstMiddleware: function() {
      return function(req, res, next) {
        console.dir('test firstMiddleware');
        return next();
      };
    },
    route: routeInfos,
    init: function(app) {}
  };

  module.exports = config;

}).call(this);
