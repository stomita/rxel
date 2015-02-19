# Rxel

A library to help describing reactive behavior in simple definition.

## Example

```coffeescript
Rxel = require "rxel"
$ = require ""

sc = Rxel.scope
  name: "John"
  message: Rxel.calc (name) -> "Hello, #{name}"
  keyword: "apple"
  searchResult: Rxel.calc (keyword) ->
    $.getJSON "http://example.com/search.json?q=#{name}"

sc.$get("message").then (message) ->
  assert message == "Hello, John"

sc.$("searchResult").subscribe (result) ->
  console.log result

$("input[name=keyword]").on "keyup", (e) ->
  sc.$set "keyword", $(@).val()

```

