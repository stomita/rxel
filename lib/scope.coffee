###
# scope.coffee
###
Rx = require "rx"
_ = require "lodash"
Promise = require "promise"


#
isPromiseLike = (v) ->
  _.isObject(v) && _.isFunction(v.then)


#
#
#
class VarNode extends Rx.BehaviorSubject
  constructor: (@name, source) ->
    super()
    @_source = null
    @_subscription = null
    @assign source if source

  assign: (@_source) ->
    unless @_source instanceof Rx.Observable
      @_source = Rx.Observable.return(@_source)
    if @_subscription
      @_subscription.dispose()
      @_subscription = @_source?.subscribe(
        (v) => @onNext(v)
        (e) => @onError(e)
      )

  subscribe: ->
    unless @_subscription
      @_subscription = @_source?.subscribe(
        (v) => @onNext(v)
        (e) => @onError(e)
      )
    sb = super
    Rx.Disposable.create =>
      sb.dispose()
      unless @hasObservers()
        @_subscription.dispose()
        @_subscription = null

  promise: ->
    new Promise (resolve, reject) => @take(1).subscribe(resolve, reject)


#
#
#
class Scope
  constructor: (config={}) ->
    @_varNodes = {}
    @$def(name, definition) for name, definition of config

  $: (name) ->
    @_varNodes[name] = @_varNodes[name] || new VarNode(name)

  $def: (name, definition) ->
    source = buildObservable(@, definition)
    @$set(name, source)
    @

  $get: (name) ->
    @$(name).promise()

  $set: (name, value) ->
    @$(name).assign(value)
    @


#
#
buildObservable = (scope, definition) ->
  if _.isObject(definition)
    switch (definition.$type)
      when "calc"
        buildCalcFnObservable(scope, definition)
      else
        throw new Error("no varnode type found: #{definition.$type}")
  else
    Rx.Observable.return(definition)

#
#
buildCalcFnObservable = (scope, definition) ->
  fn = definition.fn
  args = definition.args || 
    fn.toString()
      .match(/^function\s+\w*\(([^)]*)\)/)?[1]
      .split(/\s*,\s*/)
      .filter (x) -> x
  Rx.Observable.combineLatest(
    args.map (a) => scope.$(a)
    ->
      ret = fn.apply null, arguments
      if isPromiseLike(ret)
        Rx.Observable.fromPromise(ret)
      else
        Rx.Observable.return(ret)
  )
  .flatMap (v) -> v


#
#
#
module.exports = Scope
