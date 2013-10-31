/**!
* Copyright(c) 2012 vicanso 墨鱼仔
* MIT Licensed
*/


(function() {
  var config, errorHandler, errorJson, errorPage, express, expressErrorHandler, resIsAvailable;

  express = require('express');

  config = require('../config');

  expressErrorHandler = express.errorHandler();

  errorHandler = {
    /**
     * handler 返回错误信息处理函数
     * @return {Function} express middleware
    */

    handler: function() {
      return function(err, req, res, next) {
        var accept;
        if (!config.isProductionMode) {
          return expressErrorHandler(err, req, res, next);
        } else {
          accept = req.headers.accept || '';
          if (~accept.indexOf('json')) {
            return errorJson(err, res);
          } else {
            return errorPage(err, res);
          }
        }
      };
    }
  };

  errorPage = function(err, res) {
    var statusCode;
    if (resIsAvailable(res)) {
      statusCode = err.status || err.code || 500;
      return res.send(statusCode, err.message);
    }
  };

  errorJson = function(err, res) {
    var data, statusCode;
    data = {
      code: err.code,
      err: err.message,
      msg: err.msg
    };
    if (!config.isProductionMode) {
      data.stack = err.stack;
    }
    if (resIsAvailable(res)) {
      statusCode = err.status || err.code || 500;
      return res.json(statusCode, data);
    }
  };

  /**
     * resIsAvailable 判断response是否可用
     * @param  {response} res response对象
     * @return {Boolean}
  */


  resIsAvailable = function(res) {
    return !res.headerSent;
  };

  module.exports = errorHandler;

}).call(this);
