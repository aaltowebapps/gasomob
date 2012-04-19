###
  Main initialization for client side.
###

# Use double curvy braces -syntax with underscore templates.
_.templateSettings =
  interpolate : /\{\{(.+?)\}\}/g
  evaluate    : /<%([\s\S]+?)%>/g
  escape      : /<%-([\s\S]+?)%>/g

# Initialize socket for data syncing.
window.socket = io.connect '/'

# Load all templates and init app on callback.
Gaso.util.loadTemplates [], ->
  Gaso.log 'Templates loaded'
  #Gaso.log Gaso.util.getTemplate 'station-details'
  
  $ -> # Start application after document is ready
    Gaso.app.router = new Gaso.AppRouter()
    Backbone.history.start()
