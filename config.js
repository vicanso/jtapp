/**!
* Copyright(c) 2012 vicanso 墨鱼仔
* MIT Licensed
*/


(function() {
  var path, _;

  path = require('path');

  _ = require('underscore');

  /**
   * isProductionMode 判断当前APP是否运行在production环境下
  */


  module.exports.isProductionMode = process.env.NODE_ENV === 'production';

  /**
   * getUID 获取node的uid(如果是master则返回0)
   * @return {Number} [description]
  */


  module.exports.getUID = function() {
    var cluster;
    cluster = require('cluster');
    if (this.isMaster()) {
      return 0;
    } else {
      return cluster.worker.id || -1;
    }
  };

}).call(this);
