(function() {
  var config, path, _;

  path = require('path');

  _ = require('underscore');

  config = {
    /**
     * isProductionMode 判断当前APP是否运行在production环境下
    */

    isProductionMode: process.env.NODE_ENV === 'production',
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
