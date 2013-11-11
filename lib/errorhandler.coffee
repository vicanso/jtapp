###*!
* Copyright(c) 2012 vicanso 墨鱼仔
* MIT Licensed
###

express = require 'express'
config = require '../config'
expressErrorHandler = express.errorHandler()


###*
 * handler 返回错误信息处理函数
 * @return {Function} express middleware
###
handler = ->
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
    statusCode = err.status || err.code || 500
    res.send statusCode, err.message
errorJson = (err, res) ->
  data = 
    code : err.code
    err : err.message
    msg : err.msg
  if !config.isProductionMode
    data.stack = err.stack
  if resIsAvailable res
    statusCode = err.status || err.code || 500
    res.json statusCode, data
###*
   * resIsAvailable 判断response是否可用
   * @param  {response} res response对象
   * @return {Boolean}
  ###
resIsAvailable = (res) ->
  !res.headerSent



module.exports.handler = handler
