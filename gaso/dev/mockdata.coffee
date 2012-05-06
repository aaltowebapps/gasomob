db = require '../lib/persistence'
# Datejs API at http://code.google.com/p/datejs/wiki/APIDocumentation
dates = require 'datejs'

stations = []

# Helper stuff
nowts = new Date()
now = ->
  new Date(nowts)

addPrice = (station, type, value, date) ->
  p =
    type: type
    value: value
  p.date = date or now()

  station.prices.push p

# Defin mock stations.

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
  prices   : []

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
  prices   : []

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
  prices   : []

addPrice s3, '95E10', 1.777, now().addDays -17
addPrice s3, '95E10', 1.6, now().addDays -18
addPrice s3, '95E10', 1.5, now().addDays -19
addPrice s3, '95E10', 1.4, now().addDays -20
addPrice s3, 'Diesel', 1.4
stations.push s3

exports.stations = stations
