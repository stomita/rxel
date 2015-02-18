###
# variable-node.coffee
###
Rx = require "rx"
Promise = require "promise"

#
#
#
class VariableNode extends Rx.BehaviorSubject
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
module.exports = VariableNode