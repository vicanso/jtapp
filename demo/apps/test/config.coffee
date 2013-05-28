routeInfos = [
  {
    route : ['/']
    jadeView : 'demo/index'
    handler : (req, res, cbf, next) ->
      cbf null, {
        title : '销售单'
      }
  }
]

config = 
  firstMiddleware : ->
    (req, res, next) ->
      console.dir 'test firstMiddleware'
      next()
  route : routeInfos
  init : (app) ->

module.exports = config