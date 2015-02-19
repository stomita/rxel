# Rxel

[![Build Status](https://travis-ci.org/stomita/rxel.svg)](https://travis-ci.org/stomita/rxel)

A library to help describing reactive behavior in simple definition.

## Example

```coffeescript
Rxel = require "rxel"
$ = require "jquery"

sc = Rxel.scope
  name: "John"
  message: Rxel.calc (name) -> "Hello, #{name}"
  keyword: undefined
  searchResult: Rxel.calc (keyword) ->
    $.getJSON "http://example.com/search.json?q=#{name}"

##
sc.message.then (message) ->
  console.log message # ==> "Hello, John"
.then ->
  sc.name = "Jane"
  sc.message
.then (message) ->
  console.log message # ==> "Hello, Jane"

##
$("input[name=keyword]").on "keyup", (e) ->
  keyword = $(@).val()
  # sc.keyword = keyword
  sc.$set "keyword", keyword

sc.$("searchResult").subscribe (result) ->
  console.log result

```

