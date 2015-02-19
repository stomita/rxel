###
# rxel.coffee
###
Scope = require "./scope"
Reference = require "./reference"

module.exports =
  Scope: Scope

  scope: (config, options={}) ->
    new Scope(config, options)

  calc: Reference.createCalcDefinition

  async: Reference.createAsyncCalcDefinition
