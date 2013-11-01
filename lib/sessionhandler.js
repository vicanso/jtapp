/**!
* Copyright(c) 2012 vicanso 墨鱼仔
* MIT Licensed
*/


(function() {
  var cookieParser, express, sessionHandler, _;

  express = require('express');

  _ = require('underscore');

  cookieParser = express.cookieParser();

  sessionHandler = {
    handler: function(config) {
      var RedisStore, complete, options, redisKey, redisOptions, sessionParser;
      redisKey = ['client', 'ttl'];
      complete = config.complete || function() {};
      delete config.complete;
      redisOptions = _.pick(config, redisKey);
      options = _.omit(config, redisKey);
      if (!options.store) {
        RedisStore = require('connect-redis')(express);
        options.store = new RedisStore(redisOptions);
      }
      sessionParser = express.session(options);
      complete(function(req, res, cbf) {
        return cookieParser(req, res, function() {
          return sessionParser(req, res, cbf);
        });
      });
      return this;
    }
  };

  module.exports.handler = sessionHandler.handler;

}).call(this);
