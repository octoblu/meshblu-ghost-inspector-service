envalid        = require 'envalid'
MeshbluConfig  = require 'meshblu-config'
SigtermHandler = require 'sigterm-handler'
Server         = require './src/server'

envConfig = {
  PORT: envalid.num({ default: 80, devDefault: 3000 })
}

class Command
  constructor: ->
    env = envalid.cleanEnv process.env, envConfig
    @serverOptions = {
      logUrl            : env.LOGURL
      logExpiresSeconds : env.LOG_EXPIRES_SECOND
      port              : env.PORTORT
    }

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    server = new Server @serverOptions
    server.run (error) =>
      return @panic error if error?

      { port } = server.address()
      console.log "MeshbluGhostInspectorService listening on port: #{port}"

    sigtermHandler = new SigtermHandler()
    sigtermHandler.register server.stop

command = new Command()
command.run()