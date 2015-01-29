_ = require 'underscore'
PathModel = require './path'
Options = require '../options'

uc = (s) -> s?.toUpperCase()
firstResult = _.compose _.first, _.compact, _.map

# Model of each column header in the table.
# Managed model - needs reference to the query, so
# that it may listen to update properties such as
# sortable, sortDirection, numOfCons, etc
module.exports = class HeaderModel extends PathModel

  defaults: -> _.extend super,
    replaces: []
    isFormatted: false
    isComposed: false
    sortable: true
    sortDirection: null
    numOfCons: 0
    minimised: false
    outerJoined: false
    expanded: Options.get('Subtables.Initially.Expanded')

  # The query is needed to update derived properties.
  constructor: (opts, @query) ->
    throw new Error('no query') unless @query?.on
    throw new Error('no options') unless opts?
    super opts.path
    @set _.omit opts, 'path'
    @listenTo @query, 'change:joins', @setOuterJoined
    @listenTo @query, 'change:sortorder', @setSortDirection
    @listenTo @query, 'change:constraints', @setConstraintNum
    @_update_attrs()

  _update_attrs: ->
    @setOuterJoined()
    @setSortDirection()
    @setConstraintNum()

  getView: ->
    {replaces, isFormatted, path} = @toJSON()
    String if replaces.length is 1 and isFormatted then replaces[0] else path

  setOuterJoined: ->
    view = @getView()
    replaces = @get 'replaces'
    outerJoined = @query.isOuterJoined view
    # This column is composed if it represents more than one replaced column.
    isComposed = (not outerJoined) and (replaces.length > 1)
    sortable = not outerJoined
    @set {outerJoined, isComposed, sortable}

  setSortDirection: ->
    replaces = @get 'replaces'
    view = @getView()
    getDirection = (p) => @query.getSortDirection p
    # Work out the sort direction of this column (which is the sort
    # direction of the path or the first available sort direction of
    # the paths it replaces in the case of formatted columns).
    direction = uc firstResult replaces.concat([view]), getDirection
    @set sortDirection: direction

  setConstraintNum: ->
    view = @getView()
    numOfCons = _.size(c for c in @query.constraints when c.path.match view)
    @set {numOfCons}

