debug  = require('debug')('meshblu-ghost-inspector-service')
_      = require 'lodash'
moment = require 'moment'


class MeshbluGhostInspectorController
  constructor: ({@meshbluGhostInspectorService}) ->
    throw new Error 'Missing meshbluGhostInspectorService' unless @meshbluGhostInspectorService?

  postResult:(request, response) =>
    { name } = request.params
    passing = _.get request.body, 'data.passing'
    currentTime = moment().utc().format()
    auth = request.headers['authorization']
    unless auth
      return response.sendError(new Error "Authentication required")

    debug "Result from Ghost Inspector for test: #{name} : Passing: #{passing} and currentTime: #{currentTime}"

    @meshbluGhostInspectorService.logResult { auth, name, passing, currentTime }, (error) =>
      return response.sendError(error) if error?
      return response.sendStatus(201)



module.exports = MeshbluGhostInspectorController
