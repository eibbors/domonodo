DomoClient = require './Client'
csv = require 'csv'

# Column data types
DOMO_COLUMN_TYPES = 
  STRING: 'STRING'
  DOUBLE: 'DOUBLE'
  LONG: 'LONG'
  DATE: 'DATE'
  DATETIME: 'DATETIME'
  DECIMAL: 'DECIMAL'

# Client for working with Domo's Data APIs
class DomoDataClient extends DomoClient
  constructor: (options={}) ->
    options.scope ?= 'data' # default our scope to data
    super(options)

  # Untested boilerplate for dataset creation
  createDataSet: (dataset, callback) ->
    # Support passing in a dataset object, generic object, or string 
    if typeof(dataset) is 'object'
      if dataset?.getFieldsObject?
        reqbody = JSON.stringify(dataset.getFieldsObject())
      else
        reqbody = JSON.stringify(dataset)
    else
      reqbody = dataset

    req =
      method: 'POST'
      uri: "https://api.domo.com/v1/datasets"
      headers:
        'content-type': 'application/json'
        accept: 'application/json'
      body: reqbody

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      callback error, response, body

  # Untested boilerplate for dataset removal
  deleteDataSet: (id, callback) ->
    if typeof(id) is 'object' and id.id? then id = id.id # Support passing dataset objects
    req =
      method: 'DELETE'
      uri: "https://api.domo.com/v1/datasets/#{id}"

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      callback error, response, body

  # Untested boilerplate for updating dataset metadata
  updateDataSet: (id, dataset, callback) ->
    # Support passing dataset objects
    if typeof(id) is 'object' and id.id? 
      if typeof(dataset) is 'function' then callback = dataset # Reassign callback function
      dataset = id
      id = id.id

    # Support passing in a dataset object, generic object, or string 
    if typeof(dataset) is 'object'
      if dataset?.getFieldsObject?
        reqbody = JSON.stringify(dataset.getFieldsObject())
      else
        reqbody = JSON.stringify(dataset)
    else
      reqbody = dataset

    req =
      method: 'PUT'
      uri: "https://api.domo.com/v1/datasets"
      headers:
        'content-type': 'application/json'
        accept: 'application/json'
      body: reqbody

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      callback error, response, body

  # Retrieves metadata, including row/column counts and dataset schema for a specific dataset. Available options:
  #   fields: Partial response filter. This allows you to control the amount of data returned.
  getDataSet: (id, options={}, callback) ->
    if typeof(id) is 'object' and id.id? then id = id.id # Support passing dataset objects
    req =
      method: 'GET'
      uri: "https://api.domo.com/v1/datasets/#{id}"
      qs:
        fields: options.fields

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      metadata = new DomoDataSet(body)
      callback error, response, metadata

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
      dslist = []
      for dataset in body
        dslist.push new DomoDataSet(dataset)
      callback error, response, dslist

  # Pull rows from a dataset in CSV format
  pullData: (id, callback) ->
    if typeof(id) is 'object' and id.id? then id = id.id # Support passing dataset objects
    req =
      method: 'GET'
      uri: "https://api.domo.com/v1/datasets/#{id}/data"
      headers:
        accept: 'text/csv'

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      csv.parse body, (error, data) =>
        callback error, response, data, body

  # Push rows to a dataset in CSV format. Available options:
  #   append: Instructions to append or replace uploaded data in a DataSet (default is 'append=false' or to replace data)
  pushData: (id, append, data, callback) ->
    # If they pass an object instead of an id, assume it's a dataset
    if typeof(id) is 'object'
      dataset = id
      if dataset.id? then id = id.id 
      # If they didn't pass data in, then use the dataset's toCSV to stringify its data
      if typeof(data) is 'function'
        callback = data
        if dataset.toCSV? 
          return dataset.toCSV (error, str) =>
            @pushData dataset, append, str, callback 
      # Support passing a dataset in the data field, as well
      else if typeof(data) is 'object' and data.toCSV? 
          return data.toCSV (error, str) =>
            @pushData dataset, append, str, callback 

    req = 
      method: 'PUT'
      uri: "https://api.domo.com/v1/datasets/#{id}/data"
      qs:
        append: append
      contentType: 'text/csv'
      headers:
        'content-type': 'text/csv'
        accept: 'text/csv'
      body: data

    @request req, (error, response, body) =>
      if error then return callback error, response, body
      callback error, response, body

  # Append to dataset shortcut for code readability
  appendData: (id, data, callback) ->
    @pushData id, true, data, callback

  # Replace dataset shortcut
  replaceData: (id, data, callback) ->
    @pushData id, false, data, callback


# Prototype class for storing dataset metadata
#   id  String  ID of the DataSet updated
#   name  String  Name of the DataSet updated
#   description String  Description of DataSet updated
#   rows  Number  The number of rows currently in the DataSet
#   columns Number  The number of columns currently in the DataSet
#   schema  Object  Column types and names  
#   createdAt String  An ISO-8601 representation of the creation date of the DataSet
#   updatedAt String  AN ISO-8601 representation of the time the DataSet was last updated
#   links Array Referential links to the DataSet
class DomoDataSet
  # Fields you can edit
  @EDITABLE_FIELDS = ['name', 'description', 'schema']

  constructor: (options={}) ->
    @_data = []
    # options.id ?= null
    # options.name ?= null
    # options.schema ?= null
    # options.rows ?= null 
    # options.columns ?= null
    for k, v of options
      @[k] = v

  # Return the column names as an array
  getColumnHeaders: ->
    headers = []
    for column in @schema?.columns
      headers.push column.name
    return headers    

  # Return the fields that are editable 
  getFieldsObject: ->
    fields = {}
    for field in DomoDataSet.EDITABLE_FIELDS
      if @[field]?
        fields[field] = @[field]
    fields

  # Return the dataset as an array of rows, with or without headers
  getData: (headers=true) ->
    if headers
      [@getColumnHeaders()].concat(@_data)
    else 
      @_data
  
  # Append a string containing CSV data to our dataset
  appendCSV: (str, callback) ->
    csv.parse str, (error, rows) =>
      unless error
        @_data = @_data.concat(rows)
      callback error, rows, @

  # Replace our data with parsed CSV string
  importCSV: (str, callback) ->
    csv.parse str, (error, rows) =>
      unless error
        @_data = rows
      callback error, rows, @

  # Stringify our data as a csv
  toCSV: (headers, callback) ->
    if typeof headers is 'function'
      callback = headers
      headers = false
    csv.stringify @getData(headers), callback


# Export our module goodies
module.exports = 
  DataClient: DomoDataClient
  DataSet: DomoDataSet
  COLUMN_TYPES: DOMO_COLUMN_TYPES