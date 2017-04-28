{beforeEach, afterEach, describe, it} = global
{expect}      = require 'chai'
sinon         = require 'sinon'
shmock        = require '@octoblu/shmock'
request       = require 'request'
enableDestroy = require 'server-destroy'
Server        = require '../../src/server'
moment        = require 'moment'

describe 'Hello', ->
  beforeEach (done) ->

    @logService = shmock()
    enableDestroy(@logService)
    @logServiceUrl = "http://localhost:#{@logService.address().port}"

    @logFn = sinon.spy()
    @logExpiresSeconds = 60
    serverOptions =
      port: undefined,
      disableLogging: true
      logFn: @logFn
      logUrl: @logServiceUrl
      logExpiresSeconds: @logExpiresSeconds

    @server = new Server serverOptions

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach ->
    @server.destroy()
    @logService.destroy()

  describe 'On GET /hello', ->
    beforeEach (done) ->

      options =
        uri: '/hello'
        baseUrl: "http://localhost:#{@serverPort}"

      request.get options, (error, @response, @body) =>
        done error

    it 'should return a 200', ->
      expect(@response.statusCode).to.equal 200

  describe 'when the service yields an error', ->
    beforeEach (done) ->
      userAuth = new Buffer('some-uuid:some-token').toString 'base64'

      @authDevice = @meshblu
        .post '/authenticate'
        .set 'Authorization', "Basic #{userAuth}"
        .reply 204

      options =
        uri: '/hello'
        baseUrl: "http://localhost:#{@serverPort}"
        auth:
          username: 'some-uuid'
          password: 'some-token'
        qs:
          hasError: true
        json: true

      request.get options, (error, @response, @body) =>
        done error

    it 'should log the error', ->
      expect(@logFn).to.have.been.called

    it 'should auth and response with 500', ->
      expect(@response.statusCode).to.equal 500

    it 'should auth the request with meshblu', ->
      @authDevice.done()

  describe.only 'On POST /results/duck', ->
    beforeEach (done) ->
      @_currentTime = moment()
      @reportResult = @logService.post '/verifications/duck'
          .send {
            success: true,
            expires: moment(@_currentTime).add(60, 'seconds').utc().format()
            testName: 'some-test'

          }
          .reply 201

      options =
        uri: '/results/duck'
        baseUrl: "http://localhost:#{@serverPort}"
        json: {
          testName: 'some-test'
          passing: true
        }

      request.post options, (error, @response, @body) => done error

    it 'should respond with a 201', ->
      expect(@response.statusCode).to.equal 201

    it 'should post the result to logservice', ->
      @reportResult.done()
