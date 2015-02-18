###
# fn.coffee
###
Rx = require "rx"
_ = require "lodash"

module.exports =
  preprocess: (fn) ->
    if _.isFunction(fn)
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
    else
      null

  build: (scope, definition) ->
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
isPromiseLike = (v) ->
  _.isObject(v) && _.isFunction(v.then)
