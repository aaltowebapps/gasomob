vows   = require 'vows'
assert = require 'assert'
util   = require 'util'

config = require '../config'
db     = require '../lib/persistence'
mock   = require '../dev/mockdata'

# Helper variables.
# console.log util.inspect(foobar, true, null, true)
stationAmt = 0

debug = (args...) ->
  console.log "DEBUG:", args...

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
    stationIds = mock.stations.map (s) -> s._id
    mock.prices.forEach (price, i) =>
      price.save (err) =>
        return @callback err if err?
        if i == lastIndex
          db.FuelPrice.findByStationIds(stationIds).count @callback
    return


###
  TESTS SETUP
###
vows
  .describe('Setup before actual tests')
  .addBatch
    # Empty mock stations and related data from database before starting.
    'cleanup mock stations':
      topic: ->
        db.Station.removeByOsmIds [1, 2, 3], @callback
        return
      'cleaning up stations done': (err, count) ->
        assert.isNull err
        # debug "Removed #{count} stations during cleanup"
  .addBatch
    'after removing mock stations':
      topic: ->
        db.FuelPrice.findByStationOsmIds [1, 2, 3], @callback
        return
      'there should be no prices in the DB for our mock stations': (err, docs) ->
        assert.isNull err
        assert.equal docs.length, 0

  .export module


###
  STATIONS TESTS
###
vows
  .describe('Stations creation')
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


  .addBatch
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

vows

  .describe('Prices creation')
  .addBatch
    'when we create prices for mock stations':
      topic: api.saveAllMockPrices
      "we'll have 17 prices for our mock stations saved in the DB": (err, count) ->
        assert.isNull err
        assert.equal count, 17
  .export module
