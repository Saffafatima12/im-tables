CoreModel = require '../core-model'

{Model: {NUMERIC_TYPES, BOOLEAN_TYPES}} = require 'imjs'

module.exports = class PathModel extends CoreModel

  defaults: ->
    path: null
    type: null
    displayName: null
    typeName: null
    parts: []
    isNumeric: false
    isBoolean: false
    isReference: false # Assumes attribute by default
    isAttribute: true

  constructor: (path) ->
    super()
    @set @pathAttributes path
    @setDisplayName path
    @setTypeName path
    @pathInfo = -> path
    # Freeze the things that should never change
    @freeze 'path', 'isNumeric', 'isBoolean', 'isReference', 'isAttribute'

  setDisplayName: (path) ->
    path.getDisplayName().then (name) =>
      @set displayName: name, parts: name.split(' > ')
      @freeze 'displayName', 'parts'

  setTypeName: (path) ->
    type = (if path.isAttribute() then path.getParent() else path).getType()
    type.getDisplayName().then (name) => @set typeName: name

  pathAttributes: (path) ->
    str = String path
    attrs =
      id: (if path.isAttribute() then str else "#{ str }.id")
      path: str
      type: path.getType().name

    if path.isAttribute()
      atype = path.getType()
      attrs.isNumeric = (atype in NUMERIC_TYPES)
      attrs.isBoolean = (atype in BOOLEAN_TYPES)
    else
      attrs.isReference = true
      attrs.isAttribute = false

    return attrs

