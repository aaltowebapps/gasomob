# Persistence
config   = require '../config'
mongoose = require 'mongoose'
mongoose.connect config.db.URL

Schema = mongoose.Schema
ObjectId = Schema.ObjectId


###
  Mongoose Schemas
###

UserSchema = new Schema
  uid : String


FuelPriceSchema = new Schema
  updater  : ObjectId
  station  : ObjectId
  city     : String
  fuelType : String
  date     :
    type    : Date
    default : Date.now


CommentSchema = new Schema
  by       : ObjectId
  title    : String
  body     : String
  date     :
    type    : Date
    default : Date.now


StationSchema = new Schema
  osmId   : 
    type  : Number
    unique : true
  name    : String
  brand   : String

  country : String
  city    : String
  street  : String
  zip     : String

  location : []

  services : [String]
  comments : [CommentSchema]


StationSchema.statics.removeByOsmIds = (ids, callback) ->
  @remove 
    osmId: $in: ids
    callback

StationSchema.statics.findByOsmIds = (ids, callback) ->
  @find 
    osmId: $in: ids
    callback


# Build geospatial index of station locations.
StationSchema.index
  location: '2d'


# TODO Testing middleware
StationSchema.pre 'save', (next) ->
  # async function to notify users in the city
  @emit 'save', @
  next()

StationSchema.pre 'set', (next, path, val, type) ->
  # Just logging how middleware for 'set' behaves, wondering if it could be used for something... --markus
  console.log "Setting #{path} to #{val} for", @, 'type?', type
  next()

FuelPriceSchema.pre 'save', (next) ->
  @emit 'save', @
  next()


# Define and export models
exports.User      = mongoose.model 'User', UserSchema
exports.Comment   = mongoose.model 'Comment', CommentSchema
exports.Station   = mongoose.model 'Station', StationSchema
exports.FuelPrice = mongoose.model 'FuelPrice', FuelPriceSchema
