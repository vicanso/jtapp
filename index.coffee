###*!
* Copyright(c) 2012 vicanso 墨鱼仔
* MIT Licensed
###
async = require 'async'
_ = require 'underscore'
express = require 'express'
JTStatic = require 'jtstatic'
isProductionMode = process.env.NODE_ENV == 'production'
noop = ->

###*
 * getConfigs 获取配置文件
 * @param  {[type]} apps          [description]
 * @param  {[type]} launchAppList =             'all' [description]
 * @param  {[type]} cbf           [description]
 * @return {[type]}               [description]
###
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
            if apps
              file = "#{apps}/#{file}/config"
            else
              file = "#{file}/config"
            configs.push require file
      cbf null, configs
  ], cbf

# express的middleware处理
middlewareHandler = (app, middleware) ->
  if _.isFunction middleware
    app.use middleware()
  else if _.isArray middleware
    _.each middleware, (mw) ->
      middlewareHandler app, mw
  else if _.isObject middleware
    app.use middleware.mount, middleware.handler()

initApp = (config, app = express()) ->
  # express的初始配置
  expressSetting = config.express || {}
  if expressSetting.enable
    _.each expressSetting.enable, (key) ->
      app.enable key
  if expressSetting.disabled
    _.each expressSetting.disabled, (key) ->
      app.disabled key
  if expressSetting.set
    _.each expressSetting.set, (value, key) ->
      app.set key, value
  # app添加到最前的middleware，可直接使用返回function或者{mount : string, handler : function}这种形式）
  firstMiddleware = config.firstMiddleware
  middlewareHandler app, firstMiddleware if firstMiddleware
  # if _.isFunction firstMiddleware
  #   app.use firstMiddleware()
  # else if _.isObject firstMiddleware
  #   app.use firstMiddleware.mount, firstMiddleware.handler()


  # 静态文件处理
  jtStatic = new JTStatic
  if config.static?.convertExts
    jtStatic.convertExts config.static.convertExts
    delete config.static.convertExts
  jtStatic.configure config.static
  if config.static.path
    if _.isArray config.static.path
      _.each config.static.path, (tmpPath) ->
        app.use config.static.urlPrefix, jtStatic.static {path : tmpPath}
    else
      app.use config.static.urlPrefix, jtStatic.static()
  if config.static.otherPaths
    _.each config.static.otherPaths, (pathOption) ->
      app.use pathOption.urlPrefix, jtStatic.static {path : pathOption.path}


  # favicon处理
  if config.favicon
    app.use express.favicon config.favicon


  if config.middleware
    middlewareHandler app, config.middleware

  # HTTP LOG
  if !isProductionMode
    app.use express.logger 'dev'

  app.use express.bodyParser {
    keepExtensions : true
  }
  app.use express.methodOverride()

  app.use app.router

  app.use require('./lib/errorhandler').handler()

  # 获取session设置
  sessionHandler = require './lib/sessionhandler'
  if _.isFunction config.session
    sessionHandler.handler config.session()

  # route handle
  routeHandler = require './lib/routehandler'
  if _.isFunction config.route
    routeHandler.initRoutes app, config.route(), jtStatic

  if _.isFunction config.init
    config.init app

  app

initApps = (configs, port, middleware, cbf) ->
  app = express()

  if _.isFunction middleware
    cbf = middleware
    middleware = null

  if middleware
    middlewareHandler app, middleware
  _.each configs, (cfg) ->
    if cfg.host
      subApp = initApp cfg
      if _.isArray cfg.host
        _.each cfg.host, (host) ->
          app.use express.vhost host, subApp
      else
        app.use express.vhost cfg.host, subApp
    else
      initApp cfg, app

  app.listen port
  # console.info "server listen on port:#{port}"
  cbf null, app

init = (setting, cbf = noop) ->
  config = require './config'
  config.maxAge = setting.maxAge
  async.waterfall [
    (cbf) ->
      getConfigs setting.apps, setting.launch, cbf
    (configs, cbf) ->
      initApps configs, setting.port, setting.middleware, cbf
  ], cbf

module.exports = 
  init : init