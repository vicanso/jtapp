_ = require 'underscore'

config = 
  host : 'ys.jennyou.com'
  express : 
    enable : ["trust proxy"]
    disabled : ["trust proxy"]
    set : 
      'view engine' : 'jade'
      views : "#{__dirname}/views"
  static : 
    path : "#{__dirname}/statics"
    mergePath : "#{__dirname}/statics/temp"
    mergeUrlPrefix : '/temp'
    maxAge : 3000
    mergeList : []
    urlPrefix : '/static'
  firstMiddleware : ->
    (req, res, next) ->
      console.dir 'app2 firstMiddleware'
      next()
  isProductionMode : process.env.NODE_ENV == 'production'
  route : ->
    routeInfos = [
      {
        # 请求类型，可以为Array、String，默认值为'get'
        type : ['get', 'post']
        # route路径，可以为Array、String
        route : ['/']
        # 模板路径
        template : 'index'
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

module.exports = config