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

c = new db.Comment
  by : ''
  title : 'Lipsum'
  body : '''
  Ten years ago a crack commando unit was sent to prison by a military court for a crime they didn't commit. 
  These men promptly escaped from a maximum security stockade to the Los Angeles underground. Today, still 
  wanted by the government, they survive as soldiers of fortune. If you have a problem and no one else can 
  help, and if you can find them, maybe you can hire the A-team.
  '''
  date : now().addMinutes -3
comments.push c
c = new db.Comment
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
comments.push c
c = new db.Comment
  by : ''
  title : 'Bacon!'
  body : '''
  Tail short loin shankle leberkas biltong turducken, ball tip capicola ham ground round.
  Pig rump sirloin, chuck tongue tri-tip pork belly ribeye andouille speck capicola. 
  Frankfurter kielbasa tri-tip pancetta, cow brisket ribeye meatloaf pork capicola pig rump 
  short loin flank. Frankfurter tenderloin beef, corned beef capicola beef ribs sausage. 
  Chicken pancetta bresaola, meatball bacon meatloaf sausage speck brisket chuck t-bone 
  capicola tail tongue. Sausage andouille short ribs pork belly swine prosciutto.
  '''
  date : now().addDays -10
comments.push c

# Define mock stations.

s1 = new db.Station
  osmId    : 'a'
  name     : 'ABC Aina valmis'
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
  osmId    : 'b'
  name     : 'Neste nesteessä'
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
  osmId    : 'c'
  name     : 'Shell siellä jossain'
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


pricesMappingResult = ->
  arr = []
  arr.push
    '95E10':
      price: 1.6
      date: now().addDays -5
      count: 1

  arr.push
    '95E10':
      price: 1.3
      date: now().addDays -2
      count: 1

  arr.push
    '98E5':
      price: 1.5
      date: now().addDays -1
      count: 1

  arr.push
    '98E5':
      price: 1.8
      date: now().addDays -2
      count: 1
  return ["mockstation", arr]

exports.comments = comments
exports.stations = stations
exports.prices = prices
exports.pricesMappingResult = pricesMappingResult()
