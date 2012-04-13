###
  Main initialization for client side.
###
window.socket = io.connect 'http://localhost'

# Load templates and init app on callback.
Gaso.util.loadTemplates ['user-settings-page', 'map-page', 'list-page'], ->
  Gaso.log 'Templates loaded'
  Gaso.app.router = new Gaso.AppRouter()
  Backbone.history.start()
