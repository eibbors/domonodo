DomoClient = require './Client'

# Client for working with Domo's Data APIs
class DomoDataClient extends DomoClient
  constructor: (options={}) ->
    options.scope ?= 'data' # default our scope to data
    super(options)

  # Untested boilerplate for dataset creation
  createDataSet: (dataset, callback) ->
    req =
      method: 'POST'
      uri: "https://api.domo.com/v1/datasets"
      headers:
        'content-type': 'application/json'
        accept: 'application/json'
      body: JSON.stringify(dataset)

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      callback error, response, body

  # Untested boilerplate for dataset removal
  deleteDataSet: (id, callback) ->
    req =
      method: 'DELETE'
      uri: "https://api.domo.com/v1/datasets/#{id}"

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      callback error, response, body

  # Untested boilerplate for updating dataset metadata
  updateDataSet: (id, dataset, callback) ->
    req =
      method: 'PUT'
      uri: "https://api.domo.com/v1/datasets"
      headers:
        'content-type': 'application/json'
        accept: 'application/json'
      body: JSON.stringify(dataset)

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      callback error, response, body

  # Retrieves metadata, including row/column counts and dataset schema for a specific dataset. Available options:
  #   fields: Partial response filter. This allows you to control the amount of data returned.
  getDataSet: (id, options={}, callback) ->
    req =
      method: 'GET'
      uri: "https://api.domo.com/v1/datasets/#{id}"
      qs:
        fields: options.fields

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      callback error, response, body

  # List metadata for multiple datasets tied to your account instance. Available options:
  #   sort: The DataSet field to sort by. Fields prefixed with a negative sign reverses the sort (i.e. '-name' does a reverse sort by the name of the DataSets)
  #   fields: Partial response filter. This allows you to control the amount of data returned.
  #   offset: Starting number to retrieve
  #   limit: Number of entries to retrieve
  listDataSets: (options={}, callback) ->
    req =
      method: 'GET'
      uri: "https://api.domo.com/v1/datasets"
      qs:
        sort: options.sort
        fields: options.fields
        offset: options.offset
        limit: options.limit

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      callback error, response, body

  # Pull rows from a dataset in CSV format
  pullData: (id, callback) ->
    req =
      method: 'GET'
      uri: "https://api.domo.com/v1/datasets/#{id}/data"
      headers:
        accept: 'text/csv'

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      callback error, response, body

  # Push rows to a dataset in CSV format. Available options:
  #   append: Instructions to append or replace uploaded data in a DataSet (default is 'append=false' or to replace data)
  pushData: (id, options={}, callback) ->
    req = 
      method: 'PUT'
      uri: "https://api.domo.com/v1/datasets/#{id}/data"
      qs:
        append: options.append
      headers:
        accept: 'text/csv'

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      callback error, response, body


# Prototype class for storing dataset metadata
#   id  String  ID of the DataSet updated
#   name  String  Name of the DataSet updated
#   description String  Description of DataSet updated
#   rows  Number  The number of rows currently in the DataSet
#   columns Number  The number of columns currently in the DataSet
#   createdAt String  An ISO-8601 representation of the creation date of the DataSet
#   updatedAt String  AN ISO-8601 representation of the time the DataSet was last updated
#   links Array Referential links to the DataSet
class DomoDataSetMetaData
  constructor: (options={}) ->
    # options.id ?= null
    options.name ?= null
    options.schema ?= null
    # options.rows ?= null 
    # options.columns ?= null
    for k, v of options
      @[k] = v
    

module.exports = 
  DataClient: DomoDataClient
  DataSetMetaData: DomoDataSetMetaData