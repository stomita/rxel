assert = require "power-assert"
Promise = require "promise"
Rx = require "rx"

Scope = require "../lib/scope"

#
# 
#
describe "scope", ->

  it "should create scope instance", ->
    sc = new Scope()
    assert sc

  #
  #
  describe "simple reactive", ->
    sc = new Scope
      num: 123
      func: (num) -> num * 2

    it "should get a value of primitive", (done) ->
      sc.get "num"
        .take(1)
        .subscribe (v) ->
          assert v == 123
          done()

    it "should get a value of calculated result", (done) ->
      sc.get "func"
        .take(1)
        .subscribe (v) ->
          assert v == 246
          done()

    it "should get a value for changed", (done) ->
      setTimeout ->
        sc.set "num", 321
      , 100
      sc.get "func"
        .skip(1) # skip first value before overwriting 'num' variable
        .take(1)
        .subscribe (v) ->
          assert v == 642
          done()

  #
  #
  describe "promise reactive", ->
    sc = new Scope
      message: (name) ->
        new Promise (resolve, reject) ->
          setTimeout ->
            resolve "Hello, #{name} !!!"
          , 500

    it "should get a promise result", (done) ->
      sc.get "message"
        .take(1)
        .subscribe (message) ->
          assert message == "Hello, John !!!"
      sc.get "message"
        .skip(1)
        .take(1)
        .subscribe (message) ->
          assert message == "Hello, Jane !!!"
          done()
      setTimeout ->
        sc.set "name", "John"
        setTimeout ->
          sc.set "name", "Jane"
        , 100
      , 100
