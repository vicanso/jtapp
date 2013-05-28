jtRedis = require 'jtredis'
jtRedis.configure
  query : true
  redis : 
    name : 'vicanso'
    uri : 'redis://localhost:10010'
    pwd : 'REDIS_PWD'

sessionParser = (req, res, next) ->
  next()

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
        route : ['/']
        jadeView : 'demo/index'
        middleware : [sessionParser]
        handler : (req, res, cbf, next) ->
          console.dir req.session
          cbf null, {
            title : '销售单'
          }
      }
      {
        route : '/error'
        handler : (req, res, cbf, next) ->
          cbf null, {
            name : 'nick'
          }
          # err = new Error '请求数据失败'
          # err.status = 500
          # cbf err
      }
    ]
  session : ->
    key : 'vicanso'
    secret : 'jenny&tree'
    ttl : 30 * 60
    client : jtRedis.getClient 'vicanso'
    complete : (parser) ->
      sessionParser = parser

module.exports = config