
###
 GET home page.
###
config = require '../config'
exports.index = (req, res) ->
  console.log config
  res.render 'index'
    config: config
  return

###
 GET templates
###
exports.templates = (req, res) ->
  res.render 'templates', layout: false
  return
