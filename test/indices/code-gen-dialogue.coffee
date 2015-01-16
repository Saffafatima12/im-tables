"use strict"

queries = [
  {
    name: "older than 35"
    select: ["name", "manager.name", "employees.name", "employees.age"]
    from: "Department"
    where: [ [ "employees.age", ">", 35 ] ]
  }
]
model = lang: 'py'

require 'imtables/shim'
$ = require 'jquery'

Dialogue = require 'imtables/views/code-gen-dialogue'

renderQueries = require '../lib/render-queries.coffee'
renderQueryWithCounter = require '../lib/render-query-with-counter-and-displays.coffee'

renderQuery = renderQueryWithCounter ((query) -> new Dialogue {query, model}), (v) ->
  v.show().then console.log.bind(console, 'SUCCESS'), console.error.bind(console)

$ -> renderQueries queries, renderQuery