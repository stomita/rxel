###
# variable-node.coffee
###
Rx = require "rx"
Promise = require "promise"

debug = require("debug")("rxel:variable-node")

#
#
#
class VariableNode extends Rx.Subject
  constructor: (@name, source) ->
    super(1)
    @_source = null
    @_cache = null
    @_connection = null
    @assign source if source

  assign: (@_source) ->
    debug "#{@name}: assign (connected=#{@_connection?}, observed=#{@hasObservers()})"
    unless @_source instanceof Rx.Observable
      @_source = Rx.Observable.return(@_source)
    @_reconnect() if @_connection

  _reconnect: ->
    debug "#{@name}: reconnect"
    @_disconnect(true)
    @_connect(true)

  _connect: (reconnect) ->
    debug "#{@name}: connect" unless reconnect
    if @_source
      try
        @_cache = new Rx.ReplaySubject(1)
        @_cache
  #        .distinctUntilChanged()
          .do (v) => debug "#{@name}: value = #{v}"
          .subscribe(
            (v) => @onNext(v)
            (e) => @onError(e)
          )
        @_connection = @_source
          .do (v) => debug "#{@name}: source => #{v}"
          .subscribe(
            (v) => process.nextTick => @_cache.onNext(v)
            (e) => process.nextTick => @_cache.onError(e)
          )

  _disconnect: (reconnect) ->
    debug "#{@name}: disconnect" unless reconnect
    @_connection?.dispose()
    @_connection = null
    @_cache?.dispose()
    @_cache = null

  subscribe: ->
    debug "#{@name}: subscribe"
    @_connect() unless @_connection
    sb = super
    # debug "#{@name}: observers++ =>", @observers.length
    Rx.Disposable.create =>
      sb.dispose()
      # debug "#{@name}: observers-- =>", @observers.length, ", connected:", @_connection?
      @_disconnect() if @_connection && !@hasObservers()

  promise: ->
    new Promise (resolve, reject) =>
      sb = @subscribe(
        (v) =>
          process.nextTick -> sb.dispose() 
          resolve(v)
        (e) =>
          process.nextTick -> sb.dispose() 
          reject(e)
      )
      null

#
#
#
module.exports = VariableNode