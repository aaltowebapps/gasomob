# Persistence
config = require '../config'
mongoose  = require 'mongoose'
mongoose.connect config.db.URL
