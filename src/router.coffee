MeshbluGhostInspectorController = require './controllers/meshblu-ghost-inspector-controller'

class Router
  constructor: ({ @meshbluGhostInspectorService }) ->
    throw new Error 'Missing meshbluGhostInspectorService' unless @meshbluGhostInspectorService?

  route: (app) =>
    meshbluGhostInspectorController = new MeshbluGhostInspectorController { @meshbluGhostInspectorService }

    app.post '/results/:name', meshbluGhostInspectorController.postResult

module.exports = Router
