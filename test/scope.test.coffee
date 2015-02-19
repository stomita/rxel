assert = require "power-assert"
Promise = require "promise"
Rx = require "rx"

Scope = require "../lib/scope"

debug = require("debug") "rxel:test:scope"

#
# create calculation varnode from function
#
calc = (fn) ->
  $refType: "fn"
  args: 
    fn.toString()
      .match(/^function\s+\w*\(([^)]*)\)/)?[1]
      .split(/\s*,\s*/)
      .filter (x) -> x
  fn: fn

#
# 
#
describe "scope", ->

  it "should create scope instance", ->
    sc = new Scope()
    assert sc

  #
  #
  describe "simple reactive with calculation varnode", ->
    evalCnt = {}
    sc = new Scope
      fieldA: 1
      fieldB: 2
      fieldC: 123
      plus:
        calc (fieldA, fieldB) ->
          evalCnt.plus++
          fieldA + fieldB
      multi:
        calc (fieldB, fieldC) ->
          evalCnt.multi++
          fieldB * fieldC
      output:
        calc (plus, multi) ->
          "A + B = #{plus}, B * C = #{multi}"

    beforeEach ->
      debug "---------------------------------------------"
      evalCnt =
        multi: 0
        plus: 0


    it "should get a value of primitive", (done) ->
      sc.$get("fieldA").then (v) ->
        assert v == 1
        assert evalCnt.plus == 0
        assert evalCnt.multi == 0
        done()
      null


    it "should get a value of calculated result", (done) ->
      sc.$get("plus").then (v) ->
        assert v == 3
        assert evalCnt.plus == 1
        assert evalCnt.multi == 0
        done()
      null


    it "should get a value for changed", (done) ->
      setTimeout ->
        sc.$set("fieldB", 3)
      , 100
      sc.$("multi") # reference to rx observable
        .skip(1)   # skip first value before overwriting 'num' variable
        .take(1)
        .subscribe (v) ->
          assert v == 369
          assert evalCnt.plus == 0
          assert evalCnt.multi == 2
          done()
        ,
          (e) -> done(e)
      null


    it "should not evaluate during no subscription", (done) ->
      sc.$set("fieldB", 4)
      setTimeout ->
        sc.$set("fieldC", 100)
        setTimeout ->
          sc.$get("multi").then (v) ->
            assert v == 400
            assert evalCnt.multi == 1
            done()
        , 100
      , 100


    it "should cache evaluated result if no change", (done) ->
      sc.$set("fieldA", 24)
      sc.$set("fieldB", 12)
      sc.$set("fieldC", 15)
      sc.$("output")
        .skip(2)
        .take(1)
        .subscribe (msg) ->
          assert msg == "A + B = 36, B * C = 60"
          assert evalCnt.plus == 1
          assert evalCnt.multi == 3
          done()
      setTimeout ->
        sc.$set("fieldC", 20)
        setTimeout ->
          sc.$set("fieldC", 5)
      , 100

