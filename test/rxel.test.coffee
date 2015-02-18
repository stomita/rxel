assert = require "power-assert"

Rxel = require "../lib/rxel"

#
# 
#
describe "rxel", ->

  it "should define rxel scope", ->
    sc = Rxel.scope
      name: "John"
      message: Rxel.ref.fn (name) -> "Hello, #{name}"

    sc.$get("message").then (value) ->
      assert value == "Hello, John"


