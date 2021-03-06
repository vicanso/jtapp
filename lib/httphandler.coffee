###*!
* Copyright(c) 2012 vicanso 墨鱼仔
* MIT Licensed
###
mime = require('express').mime
_ = require 'underscore'
config = require '../config'
httpHandler = 
  ###*
   * 模板处理方法
   * @param  {request} req  request
   * @param  {response} res  response
   * @param  {String} view 模板路径
   * @param  {Object} data 模板中使用到的一些数据
   * @param  {Object} headerOptions 响应的头部
   * @param  {Function} next [description]
   * @return {[type]}      [description]
  ###
  render : (req, res, view, data, headerOptions = {}, next) ->
    fileImporter = data.fileImporter
    res.render view, data, (err, html) =>
      if err
        next err
        return 
      if fileImporter
        html = appendJsAndCss html, fileImporter
      # maxAge = config.maxAge || 300

      _.defaults headerOptions, {
        'Content-Type' :'text/html'
      }
      @response req, res, html, headerOptions, next
    @
  ###*
   * response 响应请求
   * @param  {request} req request
   * @param  {response} res response
   * @param  {Object, String, Buffer} data 响应的数据
   * @param  {Object} headerOptions 响应的头部
   * @return {[type]}               [description]
  ###
  response : (req, res, data, headerOptions, next) ->
    if resIsAvailable res
      maxAge = config.maxAge
      _.defaults headerOptions, {
        'Content-Type' :'text/plain'
      }

      if req.method == 'GET' && maxAge?
        headerOptions['Cache-Control'] ?= "public, max-age=#{maxAge}"

      if headerOptions
        _.each headerOptions, (value, key) ->
          res.header key ,value
      res.send data
    else
      next new Error 'the header has been sent!'
    @
  ###*
   * json 响应json
   * @param  {[type]}   req           [description]
   * @param  {[type]}   res           [description]
   * @param  {[type]}   data          [description]
   * @param  {[type]}   headerOptions [description]
   * @param  {Function} next          [description]
   * @return {[type]}                 [description]
  ###
  json : (req, res, data, headerOptions, next) ->
    if resIsAvailable res
      maxAge = config.maxAge
      _.defaults headerOptions, {
        'Content-Type' :'application/json'
      }
      if req.method == 'GET' && maxAge
        headerOptions['Cache-Control'] ?= "public, max-age=#{maxAge}"
      if headerOptions
        _.each headerOptions, (value, key) ->
          res.header key ,value
      res.json 200, data
    else
      next new Error 'the header has been sent!'
    @

###*
 * appendJsAndCss 往HTML中插入js,css引入列表
 * @param  {String} html html内容（未包含通过FileImporter引入的js,css）
 * @param  {FileImporter} fileImporter FileImporter实例
 * @return {String} 已添加js,css的html
###
appendJsAndCss = (html, fileImporter) ->
  html = html.replace '<!--CSS_FILES_CONTAINER-->', fileImporter.exportCss config.isProductionMode
  html = html.replace '<!--JS_FILES_CONTAINER-->', fileImporter.exportJs config.isProductionMode
###*
   * resIsAvailable 判断response是否可用
   * @param  {response} res response对象
   * @return {Boolean}
  ###
resIsAvailable = (res) ->
  !res.headerSent


module.exports.render = httpHandler.render
module.exports.response = httpHandler.response
module.exports.json = httpHandler.json
