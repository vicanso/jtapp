# jtstatic - node.js的HTTP SERVER封装，只需要通过配置文件就可以实现静态文件、session、router的处理

## 特性：

- 配置简单，只需要定义静态文件的目录、启动app的路径、端口等就可以创建一个node.js的server
- 封装router的处理，只需要定义router的访问路径，处理函数，模板路径等，而无需其它的繁琐编码
- 不同的APP允许使用不同的session配置
- 允许在最开始、静态文件处理之后添加middleware，实现不同的控制方式
- 每个APP目录下必须配置config.js，该文件可提供以下方法：firstMiddleware、route、session

###Demo APP Start
```js
jtApp = require 'jtapp'
setting = 
  express : 
    enable : ["trust proxy"]
    disabled : ["trust proxy"]
    set : 
      'view engine' : 'jade'
      views : "#{__dirname}/views"
  static : 
    path : "#{__dirname}/statics"
    urlPrefix : '/static'
    mergePath : "#{__dirname}/statics/temp"
    mergeUrlPrefix : 'temp'
    maxAge : 3000
    mergeList : []
    mount : '/static'
  launch : 'all'
  favicon : ''
  apps : "#{__dirname}/apps"
  port : 10000
jtApp.init setting, (err, app) ->
  console.dir err
```

### Demo APP Config
```js
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
          err = new Error '请求数据失败'
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
      sessionParser = parser

module.exports = config
```