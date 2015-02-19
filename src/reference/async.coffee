###
# async.coffee
###
Rx = require "rx"
Promise = require "promise"

module.exports =
  build: (scope, definition) ->
    fn = definition.fn
    args = definition.args
    Rx.Observable.combineLatest(
      args.map (a) => scope.$(a)
      ->
        _args = Array.prototype.slice.call(arguments)
        promise = new Promise (resolve, reject) ->
          fn.apply null, _args.concat (err, res) ->
            if err
              reject(err)
            else
              resolve(res)
        Rx.Observable.fromPromise(promise)
    )
    .flatMap (v) -> v
