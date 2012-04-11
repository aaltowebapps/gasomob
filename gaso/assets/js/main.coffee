
# Gaso namespace structure.
class Gaso
  ###
    Public stuff
  ###
  models: {} # Model constructors.
  views: {} # View constructors.
  app: {} # Dynamic data of the running app.
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
        console.log "Loading template: #{name}"

        html = $templates.find("##{name}").html()
        _templates.tpls[name] = html if html
        index++;

        if (index < names.length)
          _loadTemplate index
        else 
          localStorage.setItem 'Templates', JSON.stringify _templates
          console.log 'Templates cached'
          callback()

      $.get "templates", (data) ->
        $templates.html data
        _loadTemplate 0
        return
    

    # Get template by name from hash of preloaded templates
    getTemplate: (name) ->
      _templates.tpls[name]

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


# Expose Gaso to window scope
window.Gaso = new Gaso