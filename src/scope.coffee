###
# scope.coffee
###
Rx = require "rx"

VariableNode = require "./variable-node"
Reference = require "./reference"

#
#
#
class Scope
  constructor: (config={}) ->
    @_varNodes = {}
    @$def(name, definition) for name, definition of config

  $: (name) ->
    @_varNodes[name] = @_varNodes[name] || new VariableNode(name)

  $def: (name, definition) ->
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
