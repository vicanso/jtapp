
/**!
* Copyright(c) 2012 vicanso 腻味
* MIT Licensed
*/


(function() {
  var config, errorHandler, express;

  express = require('express');

  config = require('../config');

  errorHandler = {
    /**
     * handler 返回错误信息处理函数
     * @return {Function} express middleware
    */

    handler: function() {
      if (config.isProductionMode) {
        return express.errorHandler({
          dumpExceptions: false,
          showStack: false
        });
      } else {
        return express.errorHandler({
          dumpExceptions: false,
          showStack: false
        });
      }
    }
  };

  module.exports = errorHandler;

}).call(this);
