request = require 'request'
moment  = require 'moment'
debug   = require('debug')('meshblu-ghost-inspector-service')


class MeshbluGhostInspectorService
  constructor: ( { @logUrl, @logExpiresSeconds} ) ->
    throw new Error 'Missing required parameter: logUrl' unless @logUrl?

  logResult: ({passing, currentTime}, callback) =>
    json = {
      success: passing
      expires: @_getExpires()
    }
    @_currentTime = currentTime
    debug "currentTime: #{currentTime} and logResult: ", json
    debug 'LOG URL in logResult: ', @logUrl

    request.post @logUrl, { json }, (error, response) =>
      return callback error if error?
      if response.statusCode > 399
        return callback new Error "Unexpected status code: #{response.statusCode}"
      callback null

  _createError: (message='Internal Service Error', code=500) =>
    error = new Error message
    error.code = code
    return error

  _getExpires: =>
    return moment(@_currentTime).add(@logExpiresSeconds, 'seconds').utc().format()

module.exports = MeshbluGhostInspectorService
