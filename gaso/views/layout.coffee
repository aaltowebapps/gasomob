###
  Coffeekup template for default page layout.
###

# Format Coffeekup's html-output to human-readable form with indents and line breaks.
@.format = true unless process.env.NODE_ENV is 'production'

@templatesversion = if process.env.NODE_ENV is 'production' then 2 else 0

doctype 5
html ->
  head ->
    meta charset: 'utf-8'

    title "#{@title} | Gaso" if @title?
    meta(name: 'description', content: @description) if @description?
    meta name: 'viewport', content:'width=device-width, initial-scale=1'
    meta name: 'apple-mobile-web-app-capable', content: 'yes'
    
    link(rel: 'canonical', href: @canonical) if @canonical?

    # Lib styles
    link rel: 'stylesheet', href: 'http://code.jquery.com/mobile/1.1.0-rc.1/jquery.mobile-1.1.0-rc.1.min.css'

    #link rel: 'icon', href: '/favicon.png'
    link rel: 'stylesheet', href: '/stylesheets/style.css'


    # Lib scripts
    script src: 'http://cdnjs.cloudflare.com/ajax/libs/json2/20110223/json2.js'

    # Libs: jQuery and jQuery Mobile
    script src: 'http://code.jquery.com/jquery-1.7.1.min.js'

    # Libs: Socket.io
    script src: '/socket.io/socket.io.js'

    # Libs: Backbone and related stuff
    script src: 'http://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.3.1/underscore-min.js'
    #script src: 'http://cdnjs.cloudflare.com/ajax/libs/backbone.js/0.9.1/backbone-min.js'
    script src: '/javascripts/lib/backbone.js'
    script src: '/javascripts/lib/backbone.iosync.js'
    script src: '/javascripts/lib/backbone.iobind.js'
    #script src: 'http://cdnjs.cloudflare.com/ajax/libs/backbone-localstorage.js/1.0/backbone.localStorage-min.js'
    script src: '/javascripts/lib/backbone.localStorage.js'

    # Libs: jQuery Mobile
    # ...but override some stuff before jQuery mobile is included
    text assets.js 'mobileinit'
    text '\n'
    script src: 'http://code.jquery.com/mobile/1.1.0-rc.1/jquery.mobile-1.1.0-rc.1.js'
    
    # Libs: Google Maps
    script src: 'http://maps.googleapis.com/maps/api/js?key=AIzaSyDcg6vsxZ6HaI32Nn24kAzrclo9SL3Rz7M&sensor=true'

    script -> "tmplVer = #{@templatesversion};"
    
    # Include rest of own scripts, ie. other but 'mobileinit'
    text assets.js 'application' # See /assets/application.coffee

  body ->
    # No body content, content will be rendered on client using client-side templates.
