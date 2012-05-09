db = require '../lib/persistence'
# Datejs API at http://code.google.com/p/datejs/wiki/APIDocumentation
dates = require 'datejs'

prices = []
comments = []
stations = []

# Helper stuff
nowts = new Date()
now = ->
  new Date(nowts)

addPrice = (station, type, value, date) ->
  p =
    _station: station._id
    type: type
    value: value
  p.date = date or now()

  prices.push new db.FuelPrice p

# Mock comments.

c1 = new db.Comment
  by : ''
  title : 'Lorem'
  body : '''
  Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
  tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
  quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
  consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
  cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
  proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  '''
  date : now().addDays -1

comments.push c1

# Define mock stations.

s1 = new db.Station
  osmId    : 1
  name     : 'Testiasema'
  brand    : 'abc'
  address:
    country  : 'Finland'
    city     : 'Espoo'
    street   : 'Perälänkuja 5'
    zip      : '00400'
  location : [24.955, 60.167]

addPrice s1, '95E10', 1.4, now().addDays -1
addPrice s1, '95E10', 1.5
addPrice s1, '98E5', 1.7, now().addDays -2
addPrice s1, '98E5', 1.6, now().addDays -3
addPrice s1, '98E5', 1.5, now().addDays -4
addPrice s1, '98E5', 1.8, now().addDays -5
stations.push s1


s2 = new db.Station
  osmId    : 2
  name     : 'Toinen mesta'
  brand    : 'nesteoil'
  address:
    country  : 'Finland'
    city     : 'Espoo'
    street   : 'Usvatie 2'
    zip      : '00530'
  location : [24.938536, 60.169696]

addPrice s2, '95E10', 1.6, now().addDays -5
addPrice s2, '95E10', 1.5, now().addDays -4
addPrice s2, '95E10', 1.4, now().addDays -3
addPrice s2, '95E10', 1.3, now().addDays -2
addPrice s2, '98E5', 1.8, now().addDays -1
addPrice s2, 'Diesel', 1.5
stations.push s2


s3 = new db.Station
  osmId    : 3
  name     : 'Kolmas mesta'
  brand    : 'shell'
  address:
    country  : 'Finland'
    city     : 'Espoo'
    street   : 'Mikäsenytolikatu 45'
    zip      : '00430'
  location : [24.945, 60.16968]

addPrice s3, '95E10', 1.777, now().addDays -17
addPrice s3, '95E10', 1.6, now().addDays -18
addPrice s3, '95E10', 1.5, now().addDays -19
addPrice s3, '95E10', 1.4, now().addDays -20
addPrice s3, 'Diesel', 1.4
stations.push s3

exports.comments = comments
exports.stations = stations
exports.prices = prices
