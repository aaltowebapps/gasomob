###
  Coffeekup template for default page layout.
###

# Format html-output to human-readable form with indents and line breaks.
@.format = true

# The template
doctype 5
html ->
  head ->
    meta charset: 'utf-8'

    title "#{@title} | Gaso" if @title?
    meta(name: 'description', content: @description) if @description?
    meta name: 'viewport', content:'width=device-width, initial-scale=1'
    
    link(rel: 'canonical', href: @canonical) if @canonical?

    # Lib styles
    link rel: 'stylesheet', href: 'http://code.jquery.com/mobile/1.1.0-rc.1/jquery.mobile-1.1.0-rc.1.min.css'

    #link rel: 'icon', href: '/favicon.png'
    link rel: 'stylesheet', href: '/stylesheets/style.css'


    # Lib scripts
    script src: 'http://cdnjs.cloudflare.com/ajax/libs/json2/20110223/json2.js'


    # Libs: Backbone
    script src: 'http://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.3.1/underscore-min.js'
    script src: 'http://cdnjs.cloudflare.com/ajax/libs/backbone.js/0.9.1/backbone-min.js'
    script src: 'http://cdnjs.cloudflare.com/ajax/libs/backbone-localstorage.js/1.0/backbone.localStorage-min.js'


    # Libs: jQuery and jQuery Mobile
    script src: 'http://code.jquery.com/jquery-1.7.1.min.js'

    # ...but override some stuff before jQuery mobile is included
    text assets.js 'clientinit'
    text '\n'

    script src: 'http://code.jquery.com/mobile/1.1.0-rc.1/jquery.mobile-1.1.0-rc.1.js'


  body ->
    div 'data-role': 'page', ->
      header 'data-role': 'header', ->
        h1 'Gaso!'
        a href: '/', title: 'Home', -> 'Home'

      div id: 'content', 'data-role': 'content', ->
        @body

    
    # Own scripts to the end of <body>
    #text assets.js 'models/user'
    text assets.js 'views/usersettingsview'
    text assets.js 'util'
    text assets.js 'main'