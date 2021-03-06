{beforeEach, afterEach, describe, it} = global
{expect}      = require 'chai'
sinon         = require 'sinon'
shmock        = require '@octoblu/shmock'
request       = require 'request'
enableDestroy = require 'server-destroy'
Server        = require '../../src/server'
moment        = require 'moment'

describe 'MeshbluGhostInspectorService', ->
  beforeEach (done) ->

    @logService = shmock()
    enableDestroy(@logService)
    @logServiceUrl = "http://localhost:#{@logService.address().port}" + "/verifications"


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


  describe 'On POST /results/duck-test', ->
    describe 'when the test has passed', ->
      beforeEach (done) ->
        @_currentTime = moment()
        @logAuth = new Buffer('some-user:some-password').toString 'base64'
        @reportResult = @logService.post '/verifications/duck-test'
            .set 'Authorization', "Basic #{@logAuth}"
            .send {
              success: true
              expires: moment(@_currentTime).add(@logExpiresSeconds, 'seconds').utc().format()
            }
            .reply 201

        options =
          uri: '/results/duck-test'
          baseUrl: "http://localhost:#{@serverPort}"
          auth: {username: 'some-user', password: 'some-password'}
          json: {
            data:
              passing: true
          }

        request.post options, (error, @response, @body) => done error

      it 'should respond with a 201', ->
        expect(@response.statusCode).to.equal 201

      it 'should post the result to logservice', ->
        @reportResult.done()

    describe 'when the test has failed', ->
      beforeEach (done) ->
        @_currentTime = moment()
        @logAuth = new Buffer('some-user:some-password').toString 'base64'
        @reportResult = @logService.post '/verifications/duck-test'
            .set 'Authorization', "Basic #{@logAuth}"
            .send {
              success: false
              expires: moment(@_currentTime).add(@logExpiresSeconds, 'seconds').utc().format()
            }
            .reply 201

        options =
          uri: '/results/duck-test'
          baseUrl: "http://localhost:#{@serverPort}"
          auth: {username: 'some-user', password: 'some-password'}
          json: {
            data:
              passing: false
          }

        request.post options, (error, @response, @body) => done error

      it 'should respond with a 201', ->
        expect(@response.statusCode).to.equal 201

      it 'should post the result to logservice', ->
        @reportResult.done()
