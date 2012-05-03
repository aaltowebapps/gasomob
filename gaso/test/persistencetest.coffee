vows   = require 'vows'
assert = require 'assert'
util   = require 'util'

config = require '../config'
db     = require '../lib/persistence'
mock   = require '../dev/mockdata'

# Helper variables.
# console.log util.inspect(foobar, true, null, true)
stationAmt = 0

console.log "\nUsing DB", config.db.URL

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


###
  TESTS SETUP
###
vows
  .describe('Setup before actual tests')
  .addBatch
    # Empty mock stations from database before starting
    'cleanup mock stations':
      topic: ->
        db.Station.removeByOsmIds [1, 2, 3], @callback
        return
      'cleanup done': (err, count) ->
        assert.isNull err
        console.log "Removed #{count} stations during cleanup"

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
