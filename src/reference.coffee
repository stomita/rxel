###
# reference.coffee
###
Rx = require "rx"
_ = require "lodash"

#
#
refTypes =
  fn: require "./reference/fn"
  async: require "./reference/async"

#
#
buildExpression = (scope, definition) ->
  if _.isObject(definition) && definition.$refType
    if refTypes[definition.$refType]?
      refTypes[definition.$refType]?.build(scope, definition)
    else
      throw new Error "No such reference type: #{definition.$refType}"
  else
    Rx.Observable.return(definition)

#
#
createCalcDefinition = (fn) ->
  if arguments.length > 1
    args = Array.prototype.slice.call(arguments, 1)
  else
    args =
      fn.toString()
        .match(/^function\s+\w*\(([^)]*)\)/)?[1]
        .split(/\s*,\s*/)
        .filter (x) -> x
  {
    $refType: "fn"
    args: args
    fn: fn
  }

#
#
createAsyncCalcDefinition = (fn) ->
  if arguments.length > 1
    args = Array.prototype.slice.call(arguments, 1)
  else
    args =
      fn.toString()
        .match(/^function\s+\w*\(([^)]*)\)/)?[1]
        .split(/\s*,\s*/)
        .filter (x) -> x
    args.pop()
  {
    $refType: "async"
    args: args
    fn: fn
  }

#
#
#
module.exports =
  buildExpression: buildExpression
  createCalcDefinition: createCalcDefinition
  createAsyncCalcDefinition: createAsyncCalcDefinition
