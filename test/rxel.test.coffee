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

    sc.message.then (value) ->
      assert value == "Hello, John"
      sc.name = "Jane"
      sc.message
    .then (value) ->
      assert value == "Hello, Jane"


  it "should define promise fn", ->
    sc = Rxel.scope
      keyword: undefined
      searchResult: Rxel.calc (keyword) ->
        util.search(keyword)

    sc.keyword = "an"
    sc.searchResult.then (items) ->
      assert.deepEqual items, [ "orange", "banana", "mango" ]
      sc.keyword = "m"
      sc.searchResult
    .then (items) ->
      assert.deepEqual items, [ "melon", "mango" ]


  it "should define async fn", ->
    sc = Rxel.scope
      keyword: undefined
      searchResult: Rxel.async (keyword, callback) ->
        util.searchAsync(keyword, callback)

    sc.keyword = "an"
    sc.searchResult.then (items) ->
      assert.deepEqual items, [ "orange", "banana", "mango" ]
      sc.keyword = "m"
      sc.searchResult
    .then (items) ->
      assert.deepEqual items, [ "melon", "mango" ]


