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
    console.warn "No Object.defineProperty() or equivalent found. Varnodes are only accessible via $get()/$set()."
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
      @$define(name, definition)

  $: (name) ->
    @_varNodes[name]

  $vars: ->
    varNode for name, varNode of @_varNodes

  $varNames: ->
    name for name, varNode of @_varNodes

  $define: (name, definition) ->
    unless @_varNodes[name]
      @_varNodes[name] = new VariableNode(name)
    unless @[name]
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
