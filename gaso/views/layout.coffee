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
    script src: 'http://code.jquery.com/jquery-1.7.1.min.js'
    script src: 'http://code.jquery.com/mobile/1.1.0-rc.1/jquery.mobile-1.1.0-rc.1.js'

    # Example "inline" coffeescript
    coffeescript ->


  body ->
    div 'data-role': 'page', ->
      header 'data-role': 'header', ->
        h1 'Gaso!'
        a href: '/', title: 'Home', -> 'Home'

      div id: 'content', 'data-role': 'content', ->
        @body

    
    footer 'data-role': 'footer', ->
      p -> a href: '/privacy', -> 'Privacy Policy'

    # Own scripts to the end of <body>?
    #script src: '/javascripts/app.js'