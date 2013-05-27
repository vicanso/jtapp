_ = require 'underscore'
config = require '../config'
FileImporter = require('jtstatic').FileImporter
httpHandler = require './httphandler'

routeHandler = 
  ###*
   * initRoutes 初始化路由处理
   * @param  {express对象} app   express的实例
   * @param  {Array} routeInfos  路由配置的信息列表
   * @return {[type]}  [description]
  ###
  initRoutes : (app, routeInfos) ->
    _.each routeInfos, (routeInfo) ->
      handle = (req, res, next) ->
        next = _.once next
        debug = !config.isProductionMode
        routeInfo.handler req, res, (err, viewData, statusCode = 200, headerOptions = {}) ->
          if err
            next err
          else if viewData
            res.status statusCode
            if statusCode > 299 && statusCode < 400
              res.redirect statusCode, viewData
            else if routeInfo.jadeView
              viewData.fileImporter = new FileImporter debug, routeInfo.staticsHost
              viewData.title ?= '未定义标题'
              httpHandler.render req, res, routeInfo.jadeView, viewData, headerOptions, next
            else
              if _.isObject viewData
                httpHandler.json req, res, viewData
              else
                httpHandler.response req, res, viewData
          else
            err = new Error "#{__filename}: the viewData is null"
            err.code = 500
            next err
        , next
      middleware = routeInfo.middleware || []
      routes = routeInfo.route
      if !_.isArray routes
        routes = [routes]
      _.each routes, (route) ->
        method = (routeInfo.type || 'get').toLowerCase()
        app[method] route, middleware, handle

module.exports = routeHandler