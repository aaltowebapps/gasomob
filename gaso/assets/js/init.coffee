###
  Main initialization for client side.
###

# Load templates and init app on callback.
Gaso.util.loadTemplates ['user-settings-page', 'map-page', 'list-page'], ->
  console.log 'Templates loaded'
  Gaso.app.router = new Gaso.AppRouter()
  Backbone.history.start()
