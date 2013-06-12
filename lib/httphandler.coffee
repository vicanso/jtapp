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
    if data
      fileImporter = data.fileImporter
      res.render view, data, (err, html) =>
        if err
          next err
          return 
        if fileImporter
          html = appendJsAndCss html, fileImporter
        _.defaults headerOptions, {
          'Content-Type' :'text/html'
          'Cache-Control' : 'public, max-age=300'
          'Last-Modified' : new Date()
        }
        @response req, res, html, headerOptions
    @
  ###*
   * response 响应请求
   * @param  {request} req request
   * @param  {response} res response
   * @param  {Object, String, Buffer} data 响应的数据
   * @param  {Object} headerOptions 响应的头部
   * @return {[type]}               [description]
  ###
  response : (req, res, data, headerOptions) ->
    if resIsAvailable res
      if headerOptions
        _.each headerOptions, (value, key) ->
          res.header key ,value
      res.send data
    @
  json : (req, res, data) ->
    if resIsAvailable res
      res.json data
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


module.exports = httpHandler
