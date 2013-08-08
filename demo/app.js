(function() {
  var jtApp, setting;

  process.env.NODE_ENV = 'production';

  jtApp = require('../index');

  setting = {
    launch: 'all',
    apps: "" + __dirname + "/apps",
    middleware: {
      mount: '/healthchecks',
      handler: function() {
        return function(req, res) {
          return res.send('OK');
        };
      }
    },
    port: 8080
  };

  jtApp.init(setting, function(err, app) {
    return console.dir(err);
  });

}).call(this);
