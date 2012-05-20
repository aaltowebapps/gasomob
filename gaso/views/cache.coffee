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
w "# For version: #{@config.version}"
w()

# Cacheable assets.
w 'CACHE:'
w "/stylesheets/style.css"

for s in stations
  for size in logoSizes
    w "/images/stationlogos/#{s}_#{size}.png"

for s in markers
  w "/images/stationmarkers/#{s}_128.png"

w()
w 'NETWORK:'
w '*'
