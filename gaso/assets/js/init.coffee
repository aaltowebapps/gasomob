###
  Main initialization for client side.
###

# Use double curvy braces -syntax with underscore templates.
_.templateSettings =
  interpolate : /\{\{(.+?)\}\}/g
  evaluate    : /<%([\s\S]+?)%>/g
  escape      : /<%-([\s\S]+?)%>/g

# Initialize socket for data syncing.
window.socket = io.connect 'http://localhost'

# Load templates and init app on callback.
Gaso.util.loadTemplates ['user-settings-page', 'map-page', 'list-page', 'station-list-item'], ->
  Gaso.log 'Templates loaded'
  Gaso.app.router = new Gaso.AppRouter()
  Backbone.history.start()
