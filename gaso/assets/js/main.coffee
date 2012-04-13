
# Define own "Gaso" namespace and base structurefor the app.
class GasoApp
  ###
    Public stuff.
  ###
  models: {} # Backbone Models, to be defined/initialized.
  views: {} # Backbone Views, to be defined/initialized.
  app: {} # Running app and other data, to be defined/initialized.
  log: (args...) ->
    console.log args... unless productionEnv
  error: (args...) ->
    if productionEnv
      alert args.join ""
    else
      console.log args...

  util: # Utilities: template handling etc.

    # Recursively pre-load all the templates for the app.
    loadTemplates: (names, callback) ->
      if _useCachedTemplates()
        callback()
        return

      _templates.ver = _getAvailableTemplatesVersion()
      $templates = $('<div/>')

      _loadTemplate = (index) =>
        name = names[index];
        Gaso.log "Loading template: #{name}"

        html = $templates.find("##{name}").html()
        _templates.tpls[name] = html if html
        index++;

        if (index < names.length)
          _loadTemplate index
        else 
          localStorage.setItem 'Templates', JSON.stringify _templates
          Gaso.log 'Templates cached'
          callback()

      $.get "templates", (data) ->
        $templates.html data
        _loadTemplate 0
        return
    

    # Get template by name from hash of preloaded templates
    getTemplate: (name) ->
      _templates.tpls[name]


    ###
     Async method to get current device location.
     @param callback Result handler function (error, position).
    ###
    getDevicePosition: (callback, options) ->
      _getGeoLocation 'getCurrentPosition', options, callback

    ###
     Async method to monitor changes in device location.
     @param callback Result handler function (error, position).
    ###
    watchDevicePosition: (callback, options) ->
      _getGeoLocation 'watchPosition', options, callback


  ###
    Private stuff
  ###

  # Hash of preloaded templates for the app.
  _templates = ver: 0, tpls: {}


  # Detect version of templates offered from server.
  _getAvailableTemplatesVersion = ->
    window.tmplVer


  # Logic for determining if we should use cached templates or not.
  _useCachedTemplates = ->
    cache = localStorage.getItem 'Templates'
    if (cache)
      try
        _templates = JSON.parse cache
      catch err
        console.error err

    tmplVer = _getAvailableTemplatesVersion()
    ###
    Used cached templates (only in production), if server templates' version is the same as stored in localStorage. 
    @see layout.coffee
    ###
    return tmplVer && _templates.ver == tmplVer


  # Common async helper method for accessing HTML5 geolocation.
  _getGeoLocation = (funcName, options, callback) ->
    # Default settings below, can be modified with options-argument.
    defaults =
      enableHighAccuracy: true
      maximumAge: 30000
      timeout: 27000
    settings = _.extend defaults, options

    # Run function, return possible identifier.
    navigator.geolocation[funcName] (position) ->
      callback null, position
      return
    , (err) ->
      callback err
      return
    , settings

# Expose Gaso to window scope.
window.Gaso = new GasoApp()