jtRedis = require 'jtredis'
jtRedis.configure
  query : true
  redis : 
    name : 'vicanso'
    uri : 'redis://localhost:10010'
    pwd : 'REDIS_PWD'
_sessionParser = null
sessionParser = (req, res, next) ->
  if !_sessionParser
    next()
  else
    _sessionParser req, res, next

config = 
  firstMiddleware : 
    mount : 'demo'
    handler : ->
      (req, res, next) ->
        console.dir 'demo firstMiddleware'
        next()
  route : ->
    routeInfos = [
      {
        # 请求类型，可以为Array、String，默认值为'get'
        type : ['get', 'post']
        # route路径，可以为Array、String
        route : ['/']
        # 模板路径
        template : 'demo/index'
        # 中间件
        middleware : [sessionParser]
        # route处理函数
        handler : (req, res, cbf, next) ->
          # 定义中有模板路径的，自动根据模板返回HTML
          cbf null, {
            title : '销售单'
          }
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
    client : jtRedis.getClient 'vicanso'
    complete : (parser) ->
      _sessionParser = parser

module.exports = config