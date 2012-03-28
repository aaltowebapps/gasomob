
###
 GET home page.
###
exports.index = (req, res) ->
  res.render 'index'
    title: 'Hello!'
  return

###
 GET templates
###
exports.templates = (req, res) ->
  res.render 'templates', layout: false
  return
