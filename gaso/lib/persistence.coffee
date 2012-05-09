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
  updater   : ObjectId
  # Using underscore-prefixed key to denote DBref-like field.
  _station  :
    type      : ObjectId
    ref       : 'Station'
    index     : true
  value     : 
    type      : Number
    min       : 0.001
  type      :  
    type      : String
    enum      : ['98E5', '95E10', 'Diesel', 'Unleaded', 'E85']
    index     : true
  date      :
    type      : Date
    default   : Date.now
    index     : true
# Make this Schema strict by default, i.e. extra properties in models don't get saved into the DB.
, strict: true

# Note: This kind of method can't be chained :/
FuelPriceSchema.statics.findByStationOsmIds = (osmIds, fields..., callback) ->
  # To query prices we need station's DB ids, so query those
  Station.findByOsmIds osmIds, ['id'], (err, stations) =>
    return callback err if err?
    # Return already if no stations found.
    return callback null, [] unless stations.length
    # Map results to only array of DB ids.
    stationDBids = stations.map (station) -> station._id
    # Query prices, use callback for results.
    FuelPrice.findByStationIds stationDBids, fields[0], callback

FuelPriceSchema.statics.findByStationIds = (stationDBids, fields..., callback) ->
  @find 
    _station: $in: stationDBids
    fields[0]
    callback


mapLatestPricesFunc = -> 
  mapped =
    price: @value 
    date: @date
    count: 1
  emit @_station, data: [
    type: @type
    pricedata: mapped
  ]

test = 0
reduceLatestPricesFunc = (station, prices) -> 
  reduced = data: []
  latestOfType = {}

  prices.forEach (price, i) ->
    p = price.data[0]
    _type = latestOfType[p.type]
    if not _type 
      reduced.data.push p
      latestOfType[p.type] =
        date: p.date
        index: reduced.data.length-1
    else
      ritem = reduced.data[_type.index]
      pd = ritem.pricedata
      if _type.date < p.date
        pd.price = p.price
        pd.date = p.date
        _type.date = p.date
      pd.count = pd.count+1

  return reduced
  


FuelPriceSchema.statics.searchLatestPrices = (stationDBids, fields..., callback) ->
  mf = mapLatestPricesFunc.toString()
  rf = reduceLatestPricesFunc.toString()
  # TODO sort the prices, do incremental map-reduce for improved performance
  FuelPrice.collection.mapReduce mf, rf, { out : "latestprices" }, (err, result) -> 
    return callback err if err?
    # TODO query the latestprices for actual collection
    console.log "Map reduce result", err, result
    callback null, result


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
  # console.log "saving station", @
  next()

###
  Parallel middleware func for 'remove' action.
  
  Note: Calling Schema.remove or Query.remove directly doesn't fire 'remove'-middleware methods,
  because it directly sends the remove command to mongodb.
  See e.g. https://github.com/LearnBoost/mongoose/issues/439.

  Use Model.remove to make the middleware fire.
###
StationSchema.pre 'remove', true, (next, done) ->
  # Remove any prices related to this station.
  FuelPrice.remove _station: @id, (err, countremoved) ->
    # Forward any possible errors.
    done(err)
  next()

StationSchema.pre 'set', (next, path, val, type) ->
  # Just logging how middleware for 'set' behaves, wondering if it could be used for something... --markus
  console.log "Setting #{path} to #{val} for", @, 'type?', type
  next()

###
  Helpher methods for StationSchema.
###
StationSchema.statics.removeByOsmIds = (ids, callback) ->
  Station.findByOsmIds ids, (err, stations) ->
    return callback err if err?
    lastIndex = stations.length - 1
    stations.forEach (s, i) ->
      s.remove (err) ->
        return callback err if err?
        # Callback after final remove succeeds.
        if i == lastIndex
          callback null, stations.length

StationSchema.statics.findByOsmIds = (ids, fields..., callback) ->
  @find 
    osmId: $in: ids
    fields[0]
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
