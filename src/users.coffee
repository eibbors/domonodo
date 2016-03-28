request = require 'request'
DomoClient = require './Client'

# Client for working with Domo's User APIs
class DomoUserClient extends DomoClient
  constructor: (options={}) ->
    options.scope ?= 'user' # default our scope to users
    super(options)

  # Retrieve a list of users tied to your account instance. available options:
  #   sort:
  #   fields:
  #   page:
  #   entries:
  listUsers: (options={}, callback) ->
    req =
      method: 'GET'
      uri: 'https://api.domo.com/v1/users'
      qs:
        sort: options.sort
        fields: options.fields
        page: options.page
        entries: options.entries

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      callback error, response, body

  # Gets user attributes for given User ID. available options:
  #   name: Specifies the name of the column
  #   fields: Partial response filter. This allows you to control the amount of data returned.
  getUser: (id, options={}, callback) ->
    req =
      method: 'GET'
      uri: "https://api.domo.com/v1/users/#{id}"
      qs:
        name: options.name
        fields: options.fields

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      callback error, response, body

  # currently throws an http 500 error during testing
  updateUser: (id, user, callback) ->
    req =
      method: 'PUT'
      uri: "https://api.domo.com/v1/users/#{id}"
      headers:
        'content-type': 'application/json'
        accept: 'application/json'
      body: JSON.stringify(user)

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      callback error, response, body

  # Unable to test on current (production) account
  deleteUser: (id, callback) ->
    req =
      method: 'DELETE'
      uri: "https://api.domo.com/v1/users/#{id}"

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      callback error, response, body

  # Unable to test on current (production) account
  createUser: (user, callback) ->
    req =
      method: 'POST'
      uri: "https://api.domo.com/v1/users"
      headers:
        'content-type': 'application/json'
        accept: 'application/json'
      body: JSON.stringify(user)

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      callback error, response, body

# Prototype class for managing user attributes
#   id  String  The ID of the user created
#   name  String  The Name of the user created
#   email String  The Email of the user created
#   role  Number  The role of the user created (available roles are: 'Admin', 'Privileged', 'Participant'
#   title Number  The title of the user created
#   phone Number  The phone of the user created
#   links Array Referential links to the user
class DomoUser
  constructor: (options={}) ->
    options.id ?= null
    options.title ?= null
    options.email ?= null 
    options.role ?= null
    options.name ?= null
    options.phone ?= null
    options.links ?= []
    for k, v of options
      @[k] = v
    
module.exports = 
  UserClient: DomoUserClient
  User: DomoUser
