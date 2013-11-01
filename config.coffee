###*!
* Copyright(c) 2012 vicanso 墨鱼仔
* MIT Licensed
###

path = require 'path'
_ = require 'underscore'

config = 
  ###*
   * isProductionMode 判断当前APP是否运行在production环境下
  ###
  isProductionMode : process.env.NODE_ENV == 'production'
  ###*
   * getUID 获取node的uid(如果是master则返回0)
   * @return {Number} [description]
  ###
  getUID : () ->
    cluster = require 'cluster'
    if @isMaster()
      0
    else
      cluster.worker.id || -1
      
module.exports.isProductionMode = config.isProductionMode
module.exports.getUID = config.getUID