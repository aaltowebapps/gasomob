###
  Persistence using Mongoose ORM Schemas.
###
config   = require '../config'
mongoose = require 'mongoose'

dbURL = config.db.URL
console.log "\nConnecting to DB", dbURL
# Connect to DB.
mongoose.connect dbURL


# Helper variables.
Schema = mongoose.Schema
ObjectId = Schema.ObjectId



###
  USER SCHEMA
###
UserSchema = new Schema
  uid : 
    type  : String
    index : true
# Make this Schema strict by default, i.e. extra properties in models don't get saved into the DB.
, strict: true



###
  FUEL PRICE SCHEMA
###
FuelPriceSchema = new Schema
  updater : ObjectId
  station : ObjectId
  value   : 
    type    : Number
    min     : 0.001
  type    :  
    type    : String
    enum    : ['98E5', '95E10', 'Diesel', 'Unleaded', 'E85']
    index   : true
  date    :
    type    : Date
    default : Date.now
    index   : true
# Make this Schema strict by default, i.e. extra properties in models don't get saved into the DB.
, strict: true



###
  COMMENT SCHEMA
###
CommentSchema = new Schema
  by      : ObjectId
  title   : String
  body    : String
  date    :
    type    : Date
    default : Date.now
# Make this Schema strict by default, i.e. extra properties in models don't get saved into the DB.
, strict: true



###
  STATION SCHEMA
###
StationSchema = new Schema
  osmId     : 
    type      : Number
    unique    : true # index and require uniqueness
  name      : String
  brand     : String

  address   :
    country   : String
    city      : String
    street    : String
    zip       : String

  updated   :
    type      : Date
    default   : Date.now

  location  : 
    type      : []
    required  : true
  services  : [String]
  comments  : 
    type      : [CommentSchema]
    select    : false
# Make this Schema strict by default, i.e. extra properties in models don't get saved into the DB.
, strict: true  

# Build geospatial index of station locations.
StationSchema.index
  location: '2d'

# TODO Testing middleware
StationSchema.pre 'save', (next) ->
  # async function to notify users in the city
  console.log "saving station", @
  next()

# Parallel middleware func
StationSchema.pre 'remove', true, (next, done) ->
  console.log 'removing', @
  next()

StationSchema.pre 'set', (next, path, val, type) ->
  # Just logging how middleware for 'set' behaves, wondering if it could be used for something... --markus
  console.log "Setting #{path} to #{val} for", @, 'type?', type
  next()

###
  Helpher methods for StationSchema.
###
StationSchema.statics.removeByOsmIds = (ids, callback) ->
  # Note: Calling Schema.remove directly doesn't fire pre-middleware methods,
  # see https://github.com/LearnBoost/mongoose/issues/439
  @remove 
    osmId: $in: ids
    callback

StationSchema.statics.findByOsmIds = (ids, callback) ->
  @find 
    osmId: $in: ids
    callback




# Define models
User      = mongoose.model 'User', UserSchema
Comment   = mongoose.model 'Comment', CommentSchema
Station   = mongoose.model 'Station', StationSchema
FuelPrice = mongoose.model 'FuelPrice', FuelPriceSchema

# Export models
exports.User      = User
exports.Comment   = Comment
exports.Station   = Station
exports.FuelPrice = FuelPrice
