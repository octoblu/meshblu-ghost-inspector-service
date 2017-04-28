enableDestroy      = require 'server-destroy'
octobluExpress     = require 'express-octoblu'
MeshbluAuth        = require 'express-meshblu-auth'
Router             = require './router'
MeshbluGhostInspectorService = require './services/meshblu-ghost-inspector-service'
moment      = require 'moment'

class Server
  constructor: (options) ->
    { @logFn, @disableLogging, @port, @logUrl, @logExpiresSeconds } = options
    throw new Error 'Missing required parameter: logUrl' unless @logUrl?
    throw new Error 'Missing required parameter: logExpiresSeconds' unless @logExpiresSeconds?


  address: =>
    @server.address()

  run: (callback) =>
    app = octobluExpress({ @logFn, @disableLogging })

    @_currentTime = moment()
    meshbluGhostInspectorService = new MeshbluGhostInspectorService { @logUrl, @_currentTime, @logExpiresSeconds }

    router = new Router { meshbluGhostInspectorService }

    router.route app

    @server = app.listen @port, callback
    enableDestroy @server

  stop: (callback) =>
    @server.close callback

  destroy: =>
    @server.destroy()

module.exports = Server
