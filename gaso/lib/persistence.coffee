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

FuelPriceSchema.post 'save', (price) ->
  # TODO With this we needlessly run map reduce for each fueltype save, we should run it once per station price-set update.
  LatestPrice.updateLatestPrices price

###
  LATEST PRICE SCHEMA
  Extension to FuelPrice Schema through map/reduce -> LatestPrice.
###
LatestPriceSchema = new Schema
  _id  :
    type      : ObjectId
    ref       : 'Station'
    index     : true
  value:
    prices: {}

mapLatestPricesFunc = -> 
  # Map/Reduce doesn't support Array as reduction result, so we define an object which has array in it.
  map = {}
  map[@type] =
    price : @value 
    date  : @date
    count : 1
  emit @_station, map

reduceLatestPricesFunc = (station, priceMaps) -> 
  # Expected input:
  ###
  priceMaps = [
    '95E10':
      price : x
      date  : y
      count : n
  ,
    '98E5':
      price : x
      date  : y
      count : n
  ,
    'Diesel': ...
  ,
    '95E10': ...
  ,
    ...
  ]
  ###

  # TODO can we make incremental reduce work with this structure? Will the whole deep strcuture of the object get
  # combined correctly when combining previously reduced data with new data?
  reducedPrices = {}

  priceMaps.forEach (prices) ->
    for fuelType, priceData of prices
      priceInReducedSet = reducedPrices[fuelType]
      if not priceInReducedSet
        # This type of price hasn't been recorded yet into reduced set, so add it as is.
        # priceData.count = 0
        reducedPrices[fuelType] = priceData
      else
        if priceInReducedSet.date < priceData.date
          # Update reduced set price data, if date is newer.
          priceInReducedSet.price = priceData.price
          priceInReducedSet.date  = priceData.date
        # Always increase count.  
        priceInReducedSet.count += priceData.count
        
  return reducedPrices
  

LatestPriceSchema.statics.updateLatestPrices = (savedPrice, callback) ->
  # TODO we want to do incremental map-reduce, what should be our update mechanism and incremental query like?
  # Should we perhaps keep track of last updated time and update latest prices for all stations periodically, or what?
  # Like: query = date: $gte: lastUpdated

  # On the other hand it's starting to feel like map/reduce is overkill here and we'd be better off with just some de-normalized data
  # i.e. directly replace latest price in the collection with the savedPrice we have here at hand.
  # (But maybe if/when we want to keep track of average/min/max-prices, then map/reduce is actually really needed?)
  mapFunc = mapLatestPricesFunc.toString()
  reduceFunc = reduceLatestPricesFunc.toString()
  # With these options we update all data in latest prices for this station.
  options =
    query:
      _station: savedPrice._station
    out : merge: "latestprices"

  FuelPrice.collection.mapReduce mapFunc, reduceFunc, options, (err, result) ->
    return unless callback?
    return callback err if err?
    callback null, result

LatestPriceSchema.statics.searchLatestPrices = (stationDBids, fields..., callback) ->
  @find
    _id: $in: stationDBids
    fields[0]
    callback


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
  stationId = @id
  FuelPrice.remove _station: stationId, (err, count) ->
    console.log "Removed #{count} prices"
    # Forward any possible errors.
    LatestPrice.remove _id: stationId, (err, count) ->
      console.log "Removed #{count} latest prices mapping"
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

###
 @param point Array of coordinates ([lon,lat]).
 @param radius Max distance from point (in kilometers).
 @param fields... (optional) Fields to return.
 @param callback (optional)
###
StationSchema.statics.findNearPoint = (point, radius, fields..., callback) ->
  maxRadius = 1000
  # Don't allow too wide queries.
  if radius > maxRadius
    callback "Maximum radius is #{maxRadius}."
  # MongoDB $near queries can be done in array form [lon, lat, distance_in_radians]
  near = point
  # Divide radius by average earth radius to get radians.
  near.push radius / 6371
  q = Station.find {}, fields[0]
  q.where location: $nearSphere: near
  # Force maximum results
  q.limit 100
  q.run callback if callback?
  return q

###
 @param box [ [lon,lat] , [lon,lat] ]
 @param fields... (optional) Fields to return
 @param callback (optional)
###
StationSchema.statics.findWithin = (box, fields..., callback) ->
  # Don't allow too wide queries.
  q = Station.find
    location: $within: $box: box
    fields[0]
  # Force maximum results
  q.limit 100
  q.run callback if callback?
  return q

# Define models
User        = mongoose.model 'User', UserSchema
Comment     = mongoose.model 'Comment', CommentSchema
Station     = mongoose.model 'Station', StationSchema
FuelPrice   = mongoose.model 'FuelPrice', FuelPriceSchema
LatestPrice = mongoose.model 'LatestPrice', LatestPriceSchema

# Export models
exports.User        = User
exports.Comment     = Comment
exports.Station     = Station
exports.FuelPrice   = FuelPrice
exports.LatestPrice = LatestPrice

# Exports for testing
exports._test =
  reduceLatestPricesFunc: reduceLatestPricesFunc
