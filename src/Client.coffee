request = require 'request'

class DomoClient
  constructor: (options={}) ->
    @clientId = options.clientId ? null
    @clientSecret = options.clientSecret ? null
    @accessToken = options.accessToken ? null
    @scope = options.scope ? null

  # Request an access token for making calls to Domo APIs 
  getToken: (options={}, callback) ->
    # If the clientId / clientSecret are provided, then update stored values
    if options.clientId? then @clientId = clientId 
    if options.clientSecret? then @clientSecret = clientSecret

    # Set up our token request options
    req = 
      method: 'GET'
      uri: 'https://api.domo.com/oauth/token'
      qs: 
        grant_type: 'client_credentials'
        scope: options.scope ? @scope
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

  # Simple wrapper function providing basic response parsing and auth configuration
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
      if options.headers?.accept is 'text/csv' then
        # Parse CSV files?
      else
        try 
          body = JSON.parse(body)
          # Some HTTP errors come in as parsable objects, so check for that
          if body.toe? then return callback body, response, body
        catch e
          # Handle JSON parsing error?
      callback null, response, body

module.exports = DomoClient