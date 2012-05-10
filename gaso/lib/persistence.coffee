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
  # Map/Reduce doesn't support Array as reduction result, so we define an object which has array in it.
  # TODO can we make incremental reduce work with this structure?
  emit @_station, data: [
    type: @type
    pricedata :
      price : @value 
      date  : @date
      count : 1
  ]

reduceLatestPricesFunc = (station, prices) -> 
  reduced = data: []
  latestOfType = {}

  prices.forEach (price, i) ->
    currPrice     = price.data[0]
    currPriceData = currPrice.pricedata
    latestPrice   = latestOfType[currPrice.type]
    if not latestPrice
      # This type of price hasn't been recorded yet into reduced set, so add it as is.
      reduced.data.push currPrice
      latestOfType[currPrice.type] =
        date  : currPriceData.date
        index : reduced.data.length - 1
    else
      priceInReducedSet = reduced.data[latestPrice.index]
      reducedPriceData  = priceInReducedSet.pricedata

      reducedPriceData.count = reducedPriceData.count + 1
      if latestPrice.date < currPriceData.date
        reducedPriceData.price = currPriceData.price
        reducedPriceData.date  = currPriceData.date
        latestPrice.date       = currPriceData.date
        
  return reduced
  


FuelPriceSchema.statics.searchLatestPrices = (stationDBids, fields..., callback) ->
  mapFunc = mapLatestPricesFunc.toString()
  reduceFunc = reduceLatestPricesFunc.toString()
  # TODO do incremental map-reduce (and sorting/limiting if needed) for improved performance, along these lines:
  ###
  options =
    # Store prevStart to alternate document in the DB
    query: date: $gte: prevStart
    # sort: date: -1
    out: reduce: "latestprices"
  ###
  options =
    out : "latestprices"
  FuelPrice.collection.mapReduce mapFunc, reduceFunc, options, (err, result) -> 
    return callback err if err?
    # TODO query the latestprices for actual collection
    LatestPrice.find
      _id: $in: stationDBids
      fields[0]
      callback


###
  Extension to FuelPrice through map/reduce -> LatestPrice.
###
LatestPriceSchema = new Schema
  _id  :
    type      : ObjectId
    ref       : 'Station'
    index     : true
  value:
    data: []

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
    type      : String
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
    # Return already if no stations found.
    return callback null, [] unless stations.length
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
User        = mongoose.model 'User', UserSchema
Comment     = mongoose.model 'Comment', CommentSchema
Station     = mongoose.model 'Station', StationSchema
FuelPrice   = mongoose.model 'FuelPrice', FuelPriceSchema
LatestPrice = mongoose.model 'LatestPrice', LatestPriceSchema

# Export models
exports.User      = User
exports.Comment   = Comment
exports.Station   = Station
exports.FuelPrice = FuelPrice

# Exports for testing
exports._test =
  reduceLatestPricesFunc: reduceLatestPricesFunc
