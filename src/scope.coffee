###
# scope.coffee
###
Rx = require "rx"

VariableNode = require "./variable-node"
Reference = require "./reference"

defineProperty =
  if Object.defineProperty?
    (obj, key, prop) ->
      Object.defineProperty(obj, key, prop)
  else if Object.prototype.__defineGetter__
    (obj, key, prop) ->
      obj.__defineGetter__ key, prop.get
      obj.__defineSetter__ key, prop.set
  else
    ->

#
#
#
class Scope
  constructor: (config={}, @_options={}) ->
    @_varNodes = {}
    for name of config
      @_varNodes[name] = @_varNodes[name] || new VariableNode(name)
    for name, definition of config
      @$def(name, definition)

  $: (name) ->
    @_varNodes[name]

  $def: (name, definition) ->
    @_varNodes[name] = @_varNodes[name] || new VariableNode(name)
    defineProperty @, name,
      get: => @$get(name)
      set: (value) => @$set(name, value)
    source = Reference.buildExpression(@, definition)
    @$set(name, source)
    @

  $get: (name) ->
    @$(name).promise()

  $set: (name, value) ->
    @$(name).assign(value)
    @

#
#
#
module.exports = Scope
