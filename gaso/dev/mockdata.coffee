db = require '../lib/persistence'

stations = []

stations.push new db.Station
  osmId    : 1
  name     : 'Testiasema'
  brand    : 'abc'
  country  : 'Finland'
  city     : 'Espoo'
  street   : 'Perälänkuja 5'
  zip      : '00400'
  location :
    lat : 60.167
    lon : 24.955


stations.push new db.Station
  osmId    : 2
  name     : 'Toinen mesta'
  brand    : 'nesteoil'
  country  : 'Finland'
  city     : 'Espoo'
  street   : 'Usvatie 2'
  zip      : '00530'
  location :
    lat : 60.169696
    lon : 24.938536


stations.push new db.Station
  osmId    : 3
  name     : 'Kolmas mesta'
  brand    : 'shell'
  country  : 'Finland'
  city     : 'Espoo'
  street   : 'Mikäsenytolikatu 45'
  zip      : '00430'
  location :
    lat : 60.16968
    lon : 24.945



exports.stations = stations
