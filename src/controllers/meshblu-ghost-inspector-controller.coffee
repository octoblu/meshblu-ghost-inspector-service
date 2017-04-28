debug   = require('debug')('meshblu-ghost-inspector-service')
_ = require 'lodash'
class MeshbluGhostInspectorController
  constructor: ({@meshbluGhostInspectorService}) ->
    throw new Error 'Missing meshbluGhostInspectorService' unless @meshbluGhostInspectorService?

  hello: (request, response) =>
    { hasError } = request.query
    @meshbluGhostInspectorService.doHello { hasError }, (error) =>
      return response.sendError(error) if error?
      response.sendStatus(200)

  postResult:(request, response) =>
    { name } = request.params
    passing = _.get request.body, 'data.passing'
    debug "Result from Ghost Inspector for test: #{name} : Passing: #{passing}"

    @meshbluGhostInspectorService.logResult { name, passing }, (error) =>
      return response.sendError(error) if error?
      return response.sendStatus(201)



module.exports = MeshbluGhostInspectorController
