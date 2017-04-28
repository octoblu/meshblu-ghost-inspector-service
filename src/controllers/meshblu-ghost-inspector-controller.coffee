debug = require 'debug', 'meshblu-ghost-inspector-service'
class MeshbluGhostInspectorController
  constructor: ({@meshbluGhostInspectorService}) ->
    throw new Error 'Missing meshbluGhostInspectorService' unless @meshbluGhostInspectorService?

  hello: (request, response) =>
    { hasError } = request.query
    @meshbluGhostInspectorService.doHello { hasError }, (error) =>
      return response.sendError(error) if error?
      response.sendStatus(200)

  postResult:(request, response) =>
    debug "Result from Ghost Inspector: ", request
    { name } = request.params
    { testName, passing } = request.body
    @meshbluGhostInspectorService.logResult { name, testName, passing }, (error) =>
      return response.sendError(error) if error?
      return response.sendStatus(201)



module.exports = MeshbluGhostInspectorController
