# Format Coffeekup's html-output to human-readable form with indents and line breaks.
@.format = true unless process.env.NODE_ENV is 'production'

# NOTE! If you update templates, update the 'templatesversion' in layout.coffee

###
  Below templates are underscore templates for now. Variables 
  TODO use plates instead?
###

# Helpers
gasofooter = (callback) ->
  footer 'data-id': 'gasonav', id: 'footer', 'data-role': 'footer', 'data-position': 'fixed', 'data-transition': 'slide', 'data-tap-toggle': 'false', callback

###
  PAGE TEMPLATES
###

# Map page -template
script type: 'text/template', id: 'map-page', ->
  #header 'data-role': 'header', ->
  #  h1 'Map'
  div 'data-role': 'content', ->
    div id: 'map-canvas'
  gasofooter ->
    partial 'navigation'


# User settings page -template
script type: 'text/template', id: 'user-settings-page', ->
  header 'data-role': 'header', ->
    h1 'Settings'
  div 'data-role': 'content', ->
    # TODO content
  gasofooter ->
    partial 'navigation'


# Station details page -template
script type: 'text/template', id: 'station-details', ->
  header 'data-role': 'header', ->
    h1 '{{ name }}'
  div 'data-role': 'content', ->
    div class: 'ui-icon-station ui-icon-{{ brand }}'
    h2 '{{ street }}'
    h3 '{{ zip }} {{ city }}'
    table ->
      tr ->
        td '95E10:'
        td ->
          input id: '95E10Price', type: 'text', value: '{{ prices["95E10"] }}'
      tr ->
        td '98E5:'
        td ->
          input id: '98E5Price', type: 'text', value: '{{ prices["98E5"] }}'
      tr ->
        td 'Diesel:'
        td ->
          input id: 'dieselPrice', type: 'text', value: '{{ prices.diesel }}'
      tr ->
        td ''
        td ->
          input id: 'saveButton', type: 'submit', value: 'Save'
    # TODO content
  gasofooter ->
    partial 'navigation'

# Stations list page -template
script type: 'text/template', id: 'list-page', ->
  header 'data-role': 'header', ->
    h1 'Stations listed'
  div 'data-role': 'content', ->
    # jQM Listview for station list items
    ul id: 'list-stations', 'data-role': 'listview', 'data-split-theme': 'b', 'data-filter': true, ->
      li id: 'stations-nearby', 'data-role': 'list-divider', 'Nearby'
      # List items will be added using 'station-list-item'-template
    # Slider for affecting stations searching/ranking.
    # TODO change filter to partial and include it into map page also?
  gasofooter ->
    div id: 'ranking-slider', 'data-role':'fieldcontain', class: 'ui-bar ui-bar-a', ->
      table id: 'slidertable', ->
        tr ->
          td class : 'slidericon', ->
            img src: 'images/euro.png', alt:'€'
          td ->
            form id: 'filterslider', ->
              input 'type':'range', 'name':'slider', 'id':'slider-0', 'value':'25', 'min':'0', 'max':'100', 'data-theme':'b'
          td class : 'slidericon', ->
            img src:'images/distance.png', alt:'km'
    partial 'navigation'


###
  COLLECTION TEMPLATES
###

# ...

###
  MODEL TEMPLATES
###

# Stations-list list-item
script type: 'text/template', id: 'station-list-item', ->
  a 'href' : '#stations/{{ id }}/refuel', ->
    img src: "../images/stationlogos/{{ brand }}_100.png"
    # alternative approach:
    # span class: 'ui-icon ui-icon-station ui-icon-{{ brand }}'
    div class: "ui-grid-c", ->
      div class: "ui-block-a", ->
        h1 '{{ name }}'
        #h3 '{{ street }}, {{ city }}'
        # TODO modify to a better layout and structure for station data in the list. Maybe common headers for prices, with fuel type headings?
      div class: "ui-block-b", ->
        h2 '{{ prices["diesel"] }}'
      div class: "ui-block-c", ->
        h2 '{{ prices["95E10"] }}'
      div class: "ui-block-d", ->
        h2 '{{ prices["98E5"] }}'
        ###
        # Station's prices
        text '<% var blocks = ["b", "c", "d"]; %>'
        text '<% _.each(prices, function(item, key) { %>'
        span '{{ key }}: {{ item }}'
        text '<% }); %>'
        ###
    p class: 'ui-li-aside distance', "{{ distance }} km"

