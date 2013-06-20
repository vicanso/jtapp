(function() {
  var jtApp, setting;

  jtApp = require('../index');

  setting = {
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
      urlPrefix: '/static',
      mergePath: "" + __dirname + "/statics/temp",
      mergeUrlPrefix: 'temp',
      maxAge: 3000,
      mergeList: [],
      mount: '/static'
    },
    maxAge: 3000 * 1000,
    launch: 'all',
    favicon: '',
    apps: "" + __dirname + "/apps",
    port: 8080
  };

  jtApp.init(setting, function(err, app) {
    return console.dir(err);
  });

}).call(this);
