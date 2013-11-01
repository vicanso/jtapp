###*!
* Copyright(c) 2012 vicanso 墨鱼仔
* MIT Licensed
###

express = require 'express'
_ = require 'underscore'

cookieParser = express.cookieParser()
sessionHandler = 
  handler : (config) ->
    redisKey = ['client', 'ttl']
    complete = config.complete || () ->
    delete config.complete
    redisOptions = _.pick config, redisKey
    options = _.omit config, redisKey
    if !options.store
      RedisStore = require('connect-redis') express
      options.store = new RedisStore redisOptions
    sessionParser = express.session options
    complete (req, res, cbf) ->
      cookieParser req, res, ->
        sessionParser req, res, cbf
    @

module.exports.handler = sessionHandler.handler