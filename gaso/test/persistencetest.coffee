vows   = require 'vows'
assert = require 'assert'
util   = require 'util'

config = require '../config'
db     = require '../lib/persistence'
mock   = require '../dev/mockdata'

# Helper variables.
# console.log util.inspect(foobar, true, null, true)
stationAmt = 0
mockStationDBIds = mock.stations.map (s) -> s._id

debug = (args...) ->
  for n in args
    console.log "DEBUG:", util.inspect(n, true, null, true)

# Helper methods and macros for testing.
# See example at http://vowsjs.org/#-macros

assertCountChangesBy = (countDelta) ->
  (err, receivedCount) ->
    expected = stationAmt + countDelta
    assert.isNull err
    assert.equal receivedCount, expected
    # Update current stations amt to asserted count.
    stationAmt = receivedCount

api =
  saveMockStation: (stationIndex) ->
    ->
      mock.stations[stationIndex].save (err) =>
        return @callback err if err?
        db.Station.count {}, @callback
      return

  saveAllMockPrices: ->
    lastIndex = mock.prices.length-1
    mock.prices.forEach (price, i) =>
      price.save (err) =>
        return @callback err if err?
        if i == lastIndex
          db.FuelPrice.findByStationIds(mockStationDBIds).count @callback
    return

###
  TESTS SETUP
###
vows.describe('Setup before actual tests')

  .addBatch
    # Empty mock stations and related data from database before starting.
    'cleanup mock stations':
      topic: ->
        db.Station.removeByOsmIds ['a', 'b', 'c'], @callback
        return
      'cleaning up stations done': (err, count) ->
        assert.isNull err
        # debug "Removed #{count} stations during cleanup"

  .addBatch
    'after removing mock stations':
      topic: ->
        db.FuelPrice.findByStationOsmIds ['a', 'b', 'c'], @callback
        return
      'there should be no prices in the DB for our mock stations': (err, docs) ->
        assert.isNull err
        assert.equal docs.length, 0

  .export module


###
  STATIONS TESTS
###
vows.describe('Stations creation')

  .addBatch
    'before testing saving':
      topic: ->
        db.Station.count {}, @callback
        return
      "we count the amount of stations in the DB": (err, count) ->
        assert.isNull err
        assert.isNotNull count
        stationAmt = count

  .addBatch
    'when we save new station (station #0)':
      topic: api.saveMockStation(0)
      'the amount of stations in the DB increases by one': assertCountChangesBy 1

      'when we save the same station(station #0) again':
        topic: api.saveMockStation(0)
        'the DB still contains the same amount of stations': assertCountChangesBy 0

  .addBatch
    'when we save a different station (station #1)':
      topic: api.saveMockStation(1)
      'the amount of stations in the DB increases by one': assertCountChangesBy 1

  .addBatch
    'when we save a different station (station #2)':
      topic: api.saveMockStation(2)
      'the amount of stations in the DB increases by one': assertCountChangesBy 1

  .export module


vows.describe('Prices creation')

  .addBatch
    'when we create prices for mock stations':
      topic: api.saveAllMockPrices
      "we'll have 17 prices for our mock stations saved in the DB": (err, count) ->
        assert.isNull err
        assert.equal count, 17

  .export module


vows.describe('Map/reduce for latest prices')

  .addBatch
    'when we test our latest prices reduction function':
      topic: ->
        return db._test.reduceLatestPricesFunc.apply @, mock.pricesMappingResult

      'The reduction works and returns expected results for mock data': (prices) ->
        assert.isNotNull prices
        assert.equal prices['95E10'].count, 2
        assert.equal prices['95E10'].price, 1.3
        assert.equal prices['98E5'].count, 2
        assert.equal prices['98E5'].price, 1.5

  .export module


vows.describe('Prices search')

  .addBatch
    'when we search latest prices for all of our mock stations':
      topic: ->
        db.FuelPrice.searchLatestPrices mockStationDBIds, @callback
        return

      "we'll get an array of prices for 3 stations": (err, prices) ->
        assert.isNull err
        assert.equal prices.length, 3

      "and latest prices for station #1 are: 1.3 for 95E10, 1.8 for 98E5 and 1.5 for Diesel": (err, prices) ->
        assert.isNull err
        # Find station #1 from the results
        temp = prices.filter (s) -> s.id == mockStationDBIds[1].toString()
        assert.equal temp.length, 1
        s1Prices = temp[0].toJSON()

        # Assert prices
        assert.equal Object.keys(s1Prices.value).length, 3
        for own fuelType, priceData of s1Prices.value
          switch fuelType
            when '95E10'  then assert.equal priceData.price, 1.3
            when '98E5'   then assert.equal priceData.price, 1.8
            when 'Diesel' then assert.equal priceData.price, 1.5
            else assert.fail "Unexpected fuel type '#{fuelType}' in the results. There should be no other fuel types but the ones we tested."

  .export module
