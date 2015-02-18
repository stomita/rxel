###
# reference.coffee
###
Rx = require "rx"
_ = require "lodash"

#
#
refTypes =
  fn: require "./reference/fn"

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

preprocessors = {}
for refType, ref of refTypes when ref.preprocess?
  preprocessors[refType] = -> ref.preprocess.apply ref, arguments

#
#
#
module.exports =
  types: refTypes
  buildExpression: buildExpression
  preprocessors: preprocessors
