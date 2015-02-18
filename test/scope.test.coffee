assert = require "power-assert"
Promise = require "promise"
Rx = require "rx"

Scope = require "../lib/scope"


#
# create calculation varnode from function
#
calc = (fn) ->
  $type: "calc"
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
    evalCnt = 0
    sc = new Scope
      fieldA: 123
      fieldB: 2
      output:
        calc (fieldA, fieldB) ->
          evalCnt++
          fieldA * fieldB

    beforeEach ->
      evalCnt = 0

    it "should get a value of primitive", (done) ->
      sc.$get("fieldA").then (v) ->
        assert v == 123
        assert evalCnt == 0
        done()

    it "should get a value of calculated result", (done) ->
      sc.$get("output").then (v) ->
        assert v == 246
        assert evalCnt == 1
        done()

    it "should get a value for changed", (done) ->
      setTimeout ->
        sc.$set("fieldB", 3)
      , 100
      sc.$("output") # reference to rx observable
        .skip(1)   # skip first value before overwriting 'num' variable
        .take(1)
        .subscribe (v) ->
          assert v == 369
          assert evalCnt == 2
          done()

    it "should not evaluate during no subscription", (done) ->
      sc.$set("fieldA", 100)
      setTimeout ->
        sc.$set("fieldB", 2)
        setTimeout ->
          sc.$get("output").then (v) ->
            assert v == 200
            assert evalCnt == 1
            done()
        , 100
      , 100

