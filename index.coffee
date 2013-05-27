async = require 'async'
_ = require 'underscore'
cluster = require 'cluster'
setting = require './setting'
config = require './config'

getConfigs = (apps, launchAppList = 'all', cbf) ->
  fs = require 'fs'
  async.waterfall [
    (cbf) ->
      if launchAppList == 'all'
        fs.readdir apps, cbf
      else
        cbf null, launchAppList
    (files, cbf) ->
      configs = []
      _.each files, (file) ->
        if file.charAt(0) != '.'
          file = "#{apps}/#{file}/config"
          configs.push require file
      cbf null, configs
  ], (err, configs) ->
    cbf err, configs


initApp = (configs) ->
  express = require 'express'
  jtLogger = require 'jtlogger'
  jtStatic = require 'jtstatic'

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
  app.use "/#{setting.static.urlPrefix}", jtStatic.static()

  # favicon处理
  if setting.favicon
    app.use express.favicon setting.favicon

  # express的middleware处理，在静态文件和favicon之后
  _.each configs, (cfg) ->
    middleware = cfg.middleware
    if _.isFunction middleware
      app.use middleware()
    else if _.isObject middleware
      app.use middleware.mount, middleware.handler()

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

  app.listen config.getListenPort()

  # route handle
  routeHandler = require './lib/routehandler'
  _.each configs, (cfg) ->
    if cfg.route
      routeHandler.initRoutes app, cfg.route


  _.each configs, (cfg) ->
    if _.isFunction cfg.init
      cfg.init app

async.waterfall [
  (cbf) ->
    getConfigs setting.apps, config.getLaunchAppList(), cbf
  (configs, cbf) ->
    initApp configs
]

