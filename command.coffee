envalid        = require 'envalid'
MeshbluConfig  = require 'meshblu-config'
SigtermHandler = require 'sigterm-handler'
OctobluRaven   = require 'octoblu-raven'
Server         = require './src/server'
_              = require 'lodash'

MISSING_ENV = 'Missing required environment variable:'

envConfig = {
  PORT: envalid.num({ default: 80, devDefault: 3000 })
}

class Command
  constructor: ->
    @octobluRaven = new OctobluRaven()
    @env = envalid.cleanEnv process.env, envConfig
    @serverOptions = {
      logUrl            : @env.LOG_URL
      logExpiresSeconds : @env.LOG_EXPIRES_SECOND
      port              : @env.PORT
    }

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    @panic new Error("#{MISSING_ENV} LOG_URL")             if _.isEmpty @env.LOG_URL
    @panic new Error("#{MISSING_ENV} LOG_EXPIRES_SECOND")  if _.isEmpty @env.LOG_EXPIRES_SECOND

    server = new Server @serverOptions
    server.run (error) =>
      return @panic error if error?

      { port } = server.address()
      console.log "MeshbluGhostInspectorService listening on port: #{port}"

    sigtermHandler = new SigtermHandler()
    sigtermHandler.register server.stop

command = new Command()
command.run()
