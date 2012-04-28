###
  Persistence using Mongoose ORM Schemas.
###
config   = require '../config'
mongoose = require 'mongoose'

# Connect to DB.
mongoose.connect config.db.URL


# Helper variables.
Schema = mongoose.Schema
ObjectId = Schema.ObjectId


###
  USER SCHEMA
###
UserSchema = new Schema
  uid : String
# Make this Schema strcit by default, i.e. extra priperties in models don't get saved into the DB.
, strict: true


###
  FUEL PRICE SCHEMA
###
FuelPriceSchema = new Schema
  updater  : ObjectId
  station  : ObjectId
  city     : String
  fuelType : String
  date     :
    type    : Date
    default : Date.now
# Make this Schema strcit by default, i.e. extra priperties in models don't get saved into the DB.
, strict: true

FuelPriceSchema.pre 'save', (next) ->
  @emit 'save', @
  next()


###
  COMMENT SCHEMA
###
CommentSchema = new Schema
  by       : ObjectId
  title    : String
  body     : String
  date     :
    type    : Date
    default : Date.now
# Make this Schema strcit by default, i.e. extra priperties in models don't get saved into the DB.
, strict: true


###
  STATION SCHEMA
###
StationSchema = new Schema
  osmId   : 
    type  : Number
    unique : true # index and require uniqueness
  name    : String
  brand   : String

  country : String
  city    : String
  street  : String
  zip     : String

  location : []

  services : [String]
  comments : [CommentSchema]
# Make this Schema strcit by default, i.e. extra priperties in models don't get saved into the DB.
, strict: true  

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

###
  Helpher methods for StationSchema.
###
StationSchema.statics.removeByOsmIds = (ids, callback) ->
  @remove 
    osmId: $in: ids
    callback

StationSchema.statics.findByOsmIds = (ids, callback) ->
  @find 
    osmId: $in: ids
    callback




# Define and export models
exports.User      = mongoose.model 'User', UserSchema
exports.Comment   = mongoose.model 'Comment', CommentSchema
exports.Station   = mongoose.model 'Station', StationSchema
exports.FuelPrice = mongoose.model 'FuelPrice', FuelPriceSchema
