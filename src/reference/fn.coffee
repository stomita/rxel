###
# fn.coffee
###
Rx = require "rx"
_ = require "lodash"

module.exports =
  build: (scope, definition) ->
    { fn, args } = definition
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
