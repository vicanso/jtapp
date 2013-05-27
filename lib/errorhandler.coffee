###*!
* Copyright(c) 2012 vicanso 腻味
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
      express.errorHandler {
        dumpExceptions : false
        showStack : false
      }
    else
      express.errorHandler {
        dumpExceptions : false
        showStack : false
      }

module.exports = errorHandler
