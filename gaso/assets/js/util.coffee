window.tpl =

  # Hash of preloaded templates for the app
  templates: ver: 0, tpls: {}


  getAvailableTemplatesVersion: ->
    $('#tplver').data('ver')


  useCachedTemplates: ->
    cache = localStorage.getItem 'Templates'
    if (cache)
      try
        @.templates = JSON.parse cache
      catch err
        console.error err
    return @.templates.ver == @.getAvailableTemplatesVersion()


  # Recursively pre-load all the templates for the app.
  # This implementation should be changed in a production environment. All the template files should be
  # concatenated in a single file.
  loadTemplates: (names, callback) ->
    if @.useCachedTemplates()
      callback()
      return

    @.templates.ver = @.getAvailableTemplatesVersion()
    $templates = $('<div/>')

    loadTemplate = (index) =>
      name = names[index];
      console.log "Loading template: #{name}"

      html = $templates.find("##{name}").html()
      @.templates.tpls[name] = html if html
      index++;

      if (index < names.length)
        loadTemplate index
      else 
        localStorage.setItem 'Templates', JSON.stringify @.templates
        console.log 'Templates cached'
        callback()

    $.get "templates", (data) ->
      $templates.html data
      loadTemplate 0
      return
  

  # Get template by name from hash of preloaded templates
  get: (name) ->
      @.templates.tpls[name]
