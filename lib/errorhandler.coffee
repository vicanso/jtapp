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
      if !config.isProductionMode
        expressErrorHandler err, req, res, next
      else
        accept = req.headers.accept || ''
        if ~accept.indexOf 'json'
          errorJson err, res
        else
          errorPage err, res

errorPage = (err, res) ->
  if resIsAvailable res
    res.send err.status || 500, err.message
errorJson = (err, res) ->
  data = 
    code : err.code
    msg : err.msg || err.message
  if !config.isProductionMode
    data.stack = err.stack
  if resIsAvailable res
    res.json err.status || 500, data
###*
   * resIsAvailable 判断response是否可用
   * @param  {response} res response对象
   * @return {Boolean}
  ###
resIsAvailable = (res) ->
  !res.headerSent

module.exports = errorHandler
