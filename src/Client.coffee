# This module contains the base DomoClient class that implements basic authorization support used by the 
#   more specific API client subclasses.
request = require 'request'

class DomoClient
	constructor: (options={}) ->
    @clientId = options.clientId ? null
    @clientSecret = options.clientSecret ? null
    @accessToken = options.accessToken ? null
    @scope = options.scope ? null

  # Request an access token for making calls to Domo APIs 
  getToken: (options={}, callback) ->
    # If the clientId / clientSecret / scope are provided, then update stored values
    if options.clientId? then @clientId = options.clientId 
    if options.clientSecret? then @clientSecret = options.clientSecret
    if options.scope? then @scope = options.scope

    # Set up our token request options
    req = 
      method: 'GET'
      uri: 'https://api.domo.com/oauth/token'
      qs: 
        grant_type: 'client_credentials'
        scope: @scope
      auth:
        user: @clientId
        pass: @clientSecret

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      if body?.access_token? 
        @accessToken = body.access_token
      else
        error = body
      callback error, response, body

  # Simple wrapper function providing JSON parsing and auth configuration
  request: (options={}, callback) ->
    # Allow passing in a URI as a string to options parameter
    if typeof options is 'string'
      options = 
        method: 'GET'
        uri: options
    # If we have an access token and the user hasn't set the auth option, then configure it to use our token
    if @accessToken
      options.auth ?= { bearer: @accessToken }
    # Submit the request
    request options, (error, response, body) =>
      if error then return callback error, response, body
      body = JSON.parse(body)
      callback null, response, body

module.exports = DomoClient
