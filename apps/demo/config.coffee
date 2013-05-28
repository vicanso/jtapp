routeInfos = [
  {
    route : ['/', '/demo']
    jadeView : 'demo/index'
    handler : (req, res, cbf, next) ->
      cbf null, {
        title : '销售单'
      }
  }
  {
    route : '/error'
    handler : (req, res, cbf, next) ->
      err = new Error '请求数据失败'
      err.status = 500
      cbf err
  }
]

config = 
  firstMiddleware : 
    mount : 'demo'
    handler : ->
      (req, res, next) ->
        console.dir 'demo firstMiddleware'
        next()
  middleware : 
    mount : 'demo'
    handler : ->
      (req, res, next) ->
        req._info =
          app : 'demo'
        next()
    
  route : routeInfos
module.exports = config