(function() {
  var commander, config, path, _;

  path = require('path');

  commander = require('commander');

  _ = require('underscore');

  (function(commander) {
    var splitArgs;
    splitArgs = function(val) {
      return val.split(',');
    };
    return commander.version('0.0.1').option('-p, --port <n>', 'listen port', parseInt).option('-s, --slaver <n>', 'slaver total', parseInt).option('-l, --launchapps <items>', 'the luanch app list, separated by ","', splitArgs).option('--log <n>', 'the log file\'s path(in production mode)').option('--err <n>', 'the error log file\'s path(in production mode)').parse(process.argv);
  })(commander);

  config = {
    /**
     * isProductionMode 判断当前APP是否运行在production环境下
    */

    isProductionMode: process.env.NODE_ENV === 'production',
    /**
     * getListenPort 返回APP的监听端口
     * @return {Number} [description]
    */

    getListenPort: function() {
      return commander.port || 10000;
    },
    /**
     * getLaunchAppList 获取启动app的列表
     * @return {Array, String} [description]
    */

    getLaunchAppList: function() {
      return commander.launchapps || 'all';
    },
    /**
     * getUID 获取node的uid(如果是master则返回0)
     * @return {Number} [description]
    */

    getUID: function() {
      var cluster;
      cluster = require('cluster');
      if (this.isMaster()) {
        return 0;
      } else {
        return cluster.worker.uniqueID || -1;
      }
    }
  };

  module.exports = config;

}).call(this);
