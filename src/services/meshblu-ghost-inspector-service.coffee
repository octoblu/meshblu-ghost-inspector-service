request = require 'request'
moment = require 'moment'

class MeshbluGhostInspectorService
  constructor: ( { @logUrl, @_currentTime , @logExpiresSeconds} ) ->
    throw new Error 'Missing required parameter: logUrl' unless @logUrl?

  doHello: ({ hasError }, callback) =>
    return callback @_createError('Not enough dancing!') if hasError?
    callback()

  logResult: ({name, testName, passing}, callback) =>
    json = {
      success: passing
      expires: @_getExpires()
      testName: testName
    }
    console.log "JSON in logResult: ", json
    console.log 'LOG URL in logResult: ', @logUrl
    @logUrl = @logUrl + "/verifications/#{name}"
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
