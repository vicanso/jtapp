###*!
* Copyright(c) 2012 vicanso 墨鱼仔
* MIT Licensed
###
_ = require 'underscore'
config = require '../config'
# FileImporter = require('jtstatic').FileImporter
httpHandler = require './httphandler'

routeHandler = 
  ###*
   * initRoutes 初始化路由处理
   * @param  {express对象} app   express的实例
   * @param  {Array} routeInfos  路由配置的信息列表
   * @return {[type]}  [description]
  ###
  initRoutes : (app, routeInfos, jtStatic) ->
    _.each routeInfos, (routeInfo) ->
      handle = (req, res, next) ->
        next = _.once next

        cbf = (err, renderData, statusCode = 200, headerOptions = {}) ->
          if err
            next err
            return
          if _.isNumber renderData
            tmp = statusCode
            statusCode = renderData
            renderData = tmp
          if _.isObject statusCode
            tmp = statusCode
            headerOptions = statusCode
            statusCode = tmp
          if !_.isNumber statusCode
            statusCode = 200
          if renderData
            template = renderData.template || routeInfo.template
            res.status statusCode
            if statusCode > 299 && statusCode < 400
              res.redirect statusCode, renderData
            else if template
              renderData.fileImporter = jtStatic.getFileImporter routeInfo.staticsHost
              httpHandler.render req, res, template, renderData, headerOptions, next
            else
              if _.isObject renderData
                httpHandler.json req, res, renderData, headerOptions, next
              else
                httpHandler.response req, res, renderData, headerOptions, next
          else
            res.status(statusCode).json {code : 0}
            
        routeInfo.handler req, res, cbf, next
      middleware = routeInfo.middleware || []
      routes = routeInfo.route
      if !_.isArray routes
        routes = [routes]
      _.each routes, (route) ->
        types = routeInfo.type || 'get'
        if !_.isArray types
          types = [types]
        _.each types, (type) ->
          method = type.toLowerCase()
          app[method] route, middleware, handle
    @
module.exports.initRoutes = routeHandler.initRoutes