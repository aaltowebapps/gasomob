vows = require 'vows'
assert  = require 'assert'

config = require '../config'
db = require '../lib/persistence'
mock = require '../dev/mockdata'

# Helper variables.
stationAmt = null

console.log "\nUsing DB", config.db.URL

# Helper methods and macros for testing.
# See example at http://vowsjs.org/#-macros
assertCount = (count) ->
  (err, receivedCount) ->
    assert.isNull err
    assert.equal receivedCount, count

api =
  saveMockStation: (stationIndex) ->
    ->
      mock.stations[stationIndex].save =>
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

      "we collect the amount of stations in the DB to variable n": (err, count) ->
        assert.isNull err
        assert.isNotNull count
        stationAmt = count


  .addBatch

    'when we save new station':
      topic: api.saveMockStation(0)

      'the DB now contains n+1 stations': assertCount stationAmt + 1


  .addBatch

    'when we save the same station again':
      topic: api.saveMockStation(0)

      'the DB still contains n+1 stations': assertCount stationAmt + 1

  .export module
