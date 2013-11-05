redis = require 'redis'
redisClient = redis.createClient()
_ = require 'underscore'
sessionParser = null


getStaticConfig = ->
  {
    path : "#{__dirname}/statics"
    mergePath : "#{__dirname}/statics/temp"
    mergeUrlPrefix : '/temp'
    maxAge : 3000
    mergeList : []
    urlPrefix : '/static'
  }

httpResponseTimeLogger = ->
  (req, res, next) ->
      return next() if res.jt_responseTime
      start = new Date
      res.jt_responseTime = true
      logRequest = _.once ->
        if start
          duration = new Date - start
          start = 0
          result = 
            type : 'http'
            method : req.method
            params : req.url
            statusCode : res.statusCode || 200
            date : new Date
            length : res._headers['content-length']
            elapsedTime : duration
      res.on 'finish', logRequest
      res.on 'close', logRequest
      next()

config = 
  host : 'localhost'
  express : 
    enable : ["trust proxy"]
    disabled : ["trust proxy"]
    set : 
      'view engine' : 'jade'
      views : "#{__dirname}/views"
  static : getStaticConfig()

  firstMiddleware : 
    mount : '/app1'
    handler : ->
      (req, res, next) ->
        console.dir 'app1 firstMiddleware'
        next()
  init : (app) ->
    console.dir app
  route : ->
    routeInfos = [
      {
        # 请求类型，可以为Array、String，默认值为'get'
        type : ['get', 'post']
        # route路径，可以为Array、String
        route : ['/']
        # 模板路径
        template : 'index'
        # 中间件
        middleware : [sessionParser]
        # route处理函数
        handler : (req, res, cbf, next) ->
          # 定义中有模板路径的，自动根据模板返回HTML
          cbf null, {
            title : '销售单'
          }, {
            'v-ttl' : '10s'
          }
      }
      {
        route : '/healthchecks'
        handler : (req, res) ->
          res.end 'aaaa'
      }
      {
        route : '/data'
        handler : (req, res, cbf) ->
          #定义中无模板路径，自动以JSON返回
          cbf null, {
            name : 'nick'
          }
      }
      {
        route : '/error'
        handler : (req, res, cbf, next) ->
          err = new Error
          err.message = '请求数据失败'
          err.code = -1
          err.status = 500
          cbf err
      }
    ]
  # 初始化session，初始化完成时，回调其complete，返回一个session parser(middleware)
  session : ->
    key : 'vicanso'
    secret : 'jenny&tree'
    ttl : 30 * 60
    client : redisClient
    complete : (parser) ->
      sessionParser = parser

module.exports = config