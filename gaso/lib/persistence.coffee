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
  uid : String
# Make this Schema strict by default, i.e. extra properties in models don't get saved into the DB.
, strict: true



###
  FUEL PRICE SCHEMA
###
FuelPriceSchema = new Schema
  updater  : ObjectId
  value    : 
    type : Number
    min  : 0
  type : 
    type      : String
    enum      : ['98E5', '95E10', 'Diesel', 'Unleaded', 'E85']
    index     : true
  date     :
    type    : Date
    default : Date.now
    index   : true
# Make this Schema strict by default, i.e. extra properties in models don't get saved into the DB.
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
# Make this Schema strict by default, i.e. extra properties in models don't get saved into the DB.
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

  lastModified:
    type    : Date
    default : Date.now

  location : 
    type     : []
    required : true
  services : [String]
  prices   : 
    ###
      This kind nested document array might not be optimal when we want to run queries for e.g. latest prices for some subset of
      stations. With this structure we may need to do e.g. map/reduce or multiple queries for that kind of needs.
      Completely separate collection (with maybe just ObjectId references) would be most flexible, but at least
      for now this structure feels easiest to comprehend and handle in simple situations.

      (For consideration: Mongoose does support DBRef-like references between collections,
       see http://mongoosejs.com/docs/populate.html)

      # TODO implement some vows-tests for testing queries etc with mockdata: based on results modify schema to use
      # DBRefs if it looks bad, or roll with this if it looks good

    ###
    type  : [FuelPriceSchema]
    index : true
    select: false
  comments : 
    type : [CommentSchema]
    select : false
# Make this Schema strict by default, i.e. extra properties in models don't get saved into the DB.
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
