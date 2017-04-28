request = require 'request'
moment  = require 'moment'
debug   = require('debug')('meshblu-ghost-inspector-service')


class MeshbluGhostInspectorService
  constructor: ( { @logUrl, @logExpiresSeconds} ) ->
    throw new Error 'Missing required parameter: logExpiresSeconds' unless @logExpiresSeconds?
    throw new Error 'Missing required parameter: logUrl' unless @logUrl?

  logResult: ({auth, name, passing, currentTime}, callback) =>
    logOptions =
      baseUrl: "#{@logUrl}"
      url:"#{name}"
      headers:
        Authorization:auth
      json:
        success: passing
        expires: @_getExpires(currentTime)

    debug "currentTime: #{currentTime} and logOptions: ", logOptions
    debug "logUrl in logResult : ", @logUrl

    request.post logOptions, (error, response) =>
      debug 'Error logging result: ', error if error?
      return callback error if error?
      if response.statusCode > 399
        return callback new Error "Unexpected status code from logging service: #{response.statusCode}"
      callback null

  _createError: (message='Internal Service Error', code=500) =>
    error = new Error message
    error.code = code
    return error

  _getExpires: (currentTime)=>
    return moment(currentTime).add(@logExpiresSeconds, 'seconds').utc().format()

module.exports = MeshbluGhostInspectorService
