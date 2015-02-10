###
# scope.coffee
###
Rx = require "rx"
_ = require "lodash"

class Scope extends Rx.Subject

  constructor: (config={}) ->
    super()
    @_varNodes = {}
    @set name, definition for name, definition of config

  get: (name) ->
    varDefStream = @_varNodes[name]?.stream || Rx.Observable.empty()
    @.filter (x) ->
      x && x[0] == name
    .map (x) ->
      x[1]
    .merge(varDefStream)
    .debounce(10)

  set: (name, definition) ->
    @unset(name)
    @_varNodes[name] = @_createVarNode(name, definition)

  _createVarNode: (name, definition) ->
    stream =
      if _.isFunction definition
        fn = definition
        args = fn.toString()
          .match(/^function\s+\w*\(([^)]*)\)/)?[1]
          .split(/\s*,\s*/)
          .filter (x) -> x
        Rx.Observable.combineLatest(
          args.map (a) => @get(a)
          ->
            fn.apply null, arguments
        )
      else
        Rx.Observable.return(definition)
    {
      stream: stream
      subscription: stream.subscribe (value) =>
        @onNext([ name, value ])
    }

  unset: (name) ->
    if @_varNodes[name]?
      @_varNodes[name].subscription.dispose()
      delete @_varNodes[name]


module.exports = Scope
