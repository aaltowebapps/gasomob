

# Init app
tpl.loadTemplates ['user-settings-page', 'map-page', 'list-page'], ->
  console.log 'Templates loaded'
  app = new AppRouter
  Backbone.history.start()
  #app.navigate("map", {trigger: true})
