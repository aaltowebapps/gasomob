@.format = true

# Helper method for writing the cache and to not have to remember the newlines.
w = (args...) ->
  arr = args
  arr.push '\n'
  text arr.join('')

# Helper variables
logoSizes = [50, 100]
markers = 'abc shell nesteoil seo teboil st1'.split(' ')
stations = 'abc shell nesteoil seo teboil st1 question'.split(' ')

w 'CACHE MANIFEST'
w "# Gaso #{@config.env.current} version: #{@config.version}"
# unless @config.env.production
#   w "# Force appcache invalidation in non-production env: #{Date.now()}"
w()

# Cacheable assets.
w 'CACHE:'
w "/stylesheets/style.css"
w "/stylesheets/highres.css"

for s in stations
  for size in logoSizes
    w "/images/stationlogos/#{s}_#{size}.png"

for s in markers
  w "/images/stationmarkers/#{s}_128.png"

w "/images/person_20.png"
w "/images/person_40.png"
w "/images/blue_ball16.png"
w "/images/blue_ball32.png"
w "/images/center.png"
w "/images/car_16.png"
w "/images/car_26.png"
w "/images/euro.png"
w "/images/distance.png"
w "/images/distance_direct_16.png"
w "/images/distance_direct_24.png"

w()
w 'NETWORK:'
w '*'
