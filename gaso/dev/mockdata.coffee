db = require '../lib/persistence'

stations = []

stations.push new db.Station
  osmId    : 1
  name     : 'Testiasema'
  brand    : 'abc'
  address:
    country  : 'Finland'
    city     : 'Espoo'
    street   : 'Perälänkuja 5'
    zip      : '00400'
  location : [24.955, 60.167]
  prices   : [
    type  : '95E10'
    value : 1.650
  ,
    type  : '98E5'
    value : 1.789
  ]


stations.push new db.Station
  osmId    : 2
  name     : 'Toinen mesta'
  brand    : 'nesteoil'
  address:
    country  : 'Finland'
    city     : 'Espoo'
    street   : 'Usvatie 2'
    zip      : '00530'
  location : [24.938536, 60.169696]
  prices   : [
    type  : '95E10'
    value : 1.650
  ,
    type  : '98E5'
    value : 1.635
  ,
    type  : 'Diesel'
    value : 1.510
  ]


stations.push new db.Station
  osmId    : 3
  name     : 'Kolmas mesta'
  brand    : 'shell'
  address:
    country  : 'Finland'
    city     : 'Espoo'
    street   : 'Mikäsenytolikatu 45'
    zip      : '00430'
  location : [24.945, 60.16968]
  prices   : [
    type  : '95E10'
    value : 1.750
  ,
    type  : 'Diesel'
    value : 1.535
  ]


exports.stations = stations
