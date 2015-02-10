Scope = require "../lib/scope"
assert = require "power-assert"


disposeAuto = (fn) ->
  (done) ->
    sub = fn (err) ->
      setTimeout ->
        sub?.dispose?()
        done(err)
      , 10


describe "scope", ->

  it "should create scope instance", ->
    sc = new Scope()
    assert sc

  describe "reactive", ->
    sc = new Scope
      num: 123
      func: (num) -> num * 2

    it "should get a value of primitive", disposeAuto (done) ->
      sc.get "num"
        .subscribe (v) ->
          assert v == 123
          done()

    it "should get a value of calculated result", disposeAuto (done) ->
      sc.get "func"
        .subscribe (v) ->
          assert v == 246
          done()

    it "should get a value for changed", disposeAuto (done) ->
      setTimeout ->
        sc.set "num", 321
      , 100
      sc.get "func"
        .skip(1) # skip first value before overwriting 'num' variable
        .subscribe (v) ->
          assert v == 642
          done()

