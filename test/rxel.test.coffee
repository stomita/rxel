assert = require "power-assert"
Promise = require "promise"

Rxel = require "../src/rxel"

debug = require("debug") "rxel:test:rxel"

#
#
util =
  dicts: 
    "apple,orange,banana,melon,mango".split(",")

  searchAsync: (keyword, callback) ->
    setTimeout ->
      items = util.dicts.filter (w) -> w.indexOf(keyword) >= 0
      callback(null, items)
    , 500

  search: (keyword) ->
    new Promise (resolve, reject) ->
      util.searchAsync keyword, (err, items) ->
        if err then reject(err) else resolve(items)


#
# 
#
describe "rxel", ->
  
  beforeEach ->
    debug "---------------------------------------------"
 
  it "should define rxel scope", ->
    sc = Rxel.scope
      name: "John"
      message: Rxel.calc (name) -> "Hello, #{name}"

    sc.$get("message").then (value) ->
      assert value == "Hello, John"
      sc.$set "name", "Jane"
      sc.$get "message"
    .then (value) ->
      assert value == "Hello, Jane"


  it "should define promise fn", ->
    sc = Rxel.scope
      keyword: "an"
      searchResult: Rxel.calc (keyword) ->
        util.search(keyword)

    sc.$get("searchResult").then (items) ->
      assert.deepEqual items, [ "orange", "banana", "mango" ]
      sc.$set "keyword", "m"
      sc.$get "searchResult"
    .then (items) ->
      assert.deepEqual items, [ "melon", "mango" ]


  it "should define async fn", ->
    sc = Rxel.scope
      keyword: "an"
      searchResult: Rxel.async (keyword, callback) ->
        util.searchAsync(keyword, callback)

    sc.$get("searchResult").then (items) ->
      assert.deepEqual items, [ "orange", "banana", "mango" ]
      sc.$set "keyword", "m"
      sc.$get "searchResult"
    .then (items) ->
      assert.deepEqual items, [ "melon", "mango" ]


