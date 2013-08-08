process.env.NODE_ENV = 'production'
jtApp = require '../index'
setting = 
  launch : 'all'
  apps : "#{__dirname}/apps"
  middleware : 
    mount : '/healthchecks'
    handler : ->
      (req, res) ->
        res.send 'OK'
  port : 8080
jtApp.init setting, (err, app) ->
  console.dir err