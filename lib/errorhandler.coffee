###*!
* Copyright(c) 2012 vicanso 墨鱼仔
* MIT Licensed
###

express = require 'express'
config = require '../config'
errorHandler = 
  ###*
   * handler 返回错误信息处理函数
   * @return {Function} express middleware
  ###
  handler : () ->
    if config.isProductionMode
      (err, req, res, next) ->
        accept = req.headers.accept || ''
        if ~accept.indexOf 'html'
          errorPage err, res
        else if ~accept.indexOf 'json'
          errorJson err, res
    else
      express.errorHandler()

errorPage = (err, res) ->
  res.setHeader 'Content-Type', 'text/html; charset=utf-8'
errorJson = (err, res) ->
  res.setHeader 'Content-Type', 'text/plain'
  res.status err.status || 500
  res.end err.message

module.exports = errorHandler
