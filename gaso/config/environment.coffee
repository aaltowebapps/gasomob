coffeekup = require 'coffeekup'
express   = require 'express'
stylus    = require 'stylus'
c_assets  = require 'connect-assets'

# Define global context for connect-assets
global.assets = assets = 
  js:{}, css:{}, img:{}


exports.configure = (app) ->

  app.configure ->
    app.set 'views', "#{__dirname}/../views"
    app.set 'view engine', 'coffee'
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use stylus.middleware src: "#{__dirname}/../public"
    app.use app.router
    app.use express.static "#{__dirname}/../public"
    
    # Define connect-assets configuration
    app.use c_assets
      #src: 'assets' #default is 'assets'-folder
      helperContext: assets


  # Special configuration rules for devel
  app.configure 'development', ->
    app.use express.errorHandler
      dumpExceptions: true, showStack: true


  # Special configuration rules for production
  app.configure 'production', ->
    app.use express.errorHandler()


  # Register CoffeeKup template-engine to Express
  app.register '.coffee', coffeekup.adapters.express
