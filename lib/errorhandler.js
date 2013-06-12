
/**!
* Copyright(c) 2012 vicanso 墨鱼仔
* MIT Licensed
*/


(function() {
  var config, errorHandler, errorJson, errorPage, express;

  express = require('express');

  config = require('../config');

  errorHandler = {
    /**
     * handler 返回错误信息处理函数
     * @return {Function} express middleware
    */

    handler: function() {
      if (config.isProductionMode) {
        return function(err, req, res, next) {
          var accept;
          accept = req.headers.accept || '';
          if (~accept.indexOf('html')) {
            return errorPage(err, res);
          } else if (~accept.indexOf('json')) {
            return errorJson(err, res);
          }
        };
      } else {
        return express.errorHandler();
      }
    }
  };

  errorPage = function(err, res) {
    return res.setHeader('Content-Type', 'text/html; charset=utf-8');
  };

  errorJson = function(err, res) {
    res.setHeader('Content-Type', 'text/plain');
    res.status(err.status || 500);
    return res.end(err.message);
  };

  module.exports = errorHandler;

}).call(this);
