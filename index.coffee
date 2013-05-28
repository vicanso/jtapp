async = require 'async'
_ = require 'underscore'
cluster = require 'cluster'
config = require './config'

getConfigs = (apps, launchAppList = 'all', cbf) ->
  fs = require 'fs'
  async.waterfall [
    (cbf) ->
      if launchAppList == 'all'
        fs.readdir apps, cbf
      else if launchAppList == 'one'
        cbf null, apps
      else
        cbf null, launchAppList
    (files, cbf) ->
      configs = []
      if _.isString files
        configs.push require files
      else
        _.each files, (file) ->
          if file.charAt(0) != '.'
            file = "#{apps}/#{file}/config"
            configs.push require file
        cbf null, configs
  ], (err, configs) ->
    cbf err, configs


initApp = (configs, setting, cbf) ->
  jtLogger = require 'jtlogger'
  jtStatic = require 'jtstatic'
  express = require 'express'
  app = express()
  


  # express的配置
  expressSetting = setting.express || {}
  if expressSetting.enable
    _.each expressSetting.enable, (key) ->
      app.enable key
  if expressSetting.disabled
    _.each expressSetting.disabled, (key) ->
      app.disabled key
  if expressSetting.set
    _.each expressSetting.set, (value, key) ->
      app.set key, value

  # first 中间件，每个应用都可以在最开始的时候添加一个中间件
  _.each configs, (cfg) ->
    firstMiddleware = cfg.firstMiddleware
    if _.isFunction firstMiddleware
      app.use firstMiddleware()
    else if _.isObject firstMiddleware
      app.use firstMiddleware.mount, firstMiddleware.handler()


  # 静态文件处理
  jtStatic.configure setting.static
  jtStatic.emptyMergePath()
  app.use setting.static.urlPrefix, jtStatic.static()

  # favicon处理
  if setting.favicon
    app.use express.favicon setting.favicon

  # express的middleware处理，在静态文件和favicon之后
  _.each configs, (cfg) ->
    middlewareHandler = (middleware) ->
      if _.isFunction middleware
        app.use middleware()
      else if _.isArray middleware
        _.each middleware, (mw) ->
          middlewareHandler mw
      else if _.isObject middleware
        app.use middleware.mount, middleware.handler()
    middlewareHandler cfg.middleware

  # HTTP LOG and limit
  if config.isProductionMode
    app.use express.limit '1mb'
    app.use jtLogger.getConnectLogger 'HTTP-INFO-LOGGER', {
      format : express.logger.tiny
    }
  else
    app.use express.logger 'dev'

  app.use express.bodyParser()
  app.use express.methodOverride()

  app.use app.router

  app.use require('./lib/errorhandler').handler()

  app.listen setting.port

  # 获取session设置
  _.each configs, (cfg) ->
    sessionHandler = require './lib/sessionhandler'
    if _.isFunction cfg.session
      sessionHandler.handler cfg.session()

  # route handle
  routeHandler = require './lib/routehandler'
  _.each configs, (cfg) ->
    if _.isFunction cfg.route
      routeHandler.initRoutes app, cfg.route()


  # 调用初始化
  _.each configs, (cfg) ->
    if _.isFunction cfg.init
      cfg.init app
  cbf null, app

init = (setting, cbf) ->
  async.waterfall [
    (cbf) ->
      getConfigs setting.apps, setting.launch, cbf
    (configs, cbf) ->
      initApp configs, setting, cbf
  ], cbf

module.exports = 
  init : init