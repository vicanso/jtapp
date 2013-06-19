###*!
* Copyright(c) 2012 vicanso 墨鱼仔
* MIT Licensed
###

express = require 'express'
config = require '../config'
expressErrorHandler = express.errorHandler()
errorHandler = 
  ###*
   * handler 返回错误信息处理函数
   * @return {Function} express middleware
  ###
  handler : () ->
    (err, req, res, next) ->
      accept = req.headers.accept || ''
      if ~accept.indexOf 'json'
        errorJson err, res
      else
        if config.isProductionMode
          errorPage err, res
        else
          expressErrorHandler err, req, res, next

errorPage = (err, res) ->
  res.send err.status || 500, err.message
errorJson = (err, res) ->
  data = 
    code : err.code
    msg : err.msg || err.message
  if !config.isProductionMode
    data.stack = err.stack
  res.json err.status || 500, data

module.exports = errorHandler
