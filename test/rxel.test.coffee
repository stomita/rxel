assert = require "power-assert"
Promise = require "promise"

Rxel = require "../lib/rxel"

util =
  dicts: 
    "apple,orange,banana,melon,mango".split(",")

  searchCallback: (keyword, callback) ->
    setTimeout ->
      items = util.dicts.filter (w) -> w.indexOf(keyword) >= 0
      callback(null, items)
    , 500

  search: (keyword) ->
    new Promise (resolve, reject) ->
      util.searchCallback keyword, (err, items) ->
        if err then reject(err) else resolve(items)


#
# 
#
describe "rxel", ->

  it "should define rxel scope", ->
    sc = Rxel.scope
      name: "John"
      message: Rxel.ref (name) -> "Hello, #{name}"

    sc.$get("message").then (value) ->
      assert value == "Hello, John"


  it "should define promised value", ->
    sc = Rxel.scope
      keyword: "an"
      searchResult: Rxel.ref (keyword) ->
        util.search(keyword)

    sc.$get("searchResult").then (items) ->
      assert.deepEqual items, [ "orange", "banana", "mango" ]
      sc.$set "keyword", "m"
      sc.$get "searchResult"
    .then (items) ->
      assert.deepEqual items, [ "melon", "mango" ]


