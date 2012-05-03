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

fuelTypeSelect = (options) ->
  firstOptionLabel = options?.firstOptionLabel or ''
  select id: 'otherType', name: 'otherType', 'data-mini': 'true', ->
    option value: '', firstOptionLabel
    option value: 'E85', 'E85'
    option value: 'Unleaded', 'Unleaded'

conditionalStationDistance = (options) ->
  text '<% if (drivingDistance) { %>'
  span class: 'distance-drive', "{{ drivingDistance }} km"
  text '<% } else if (directDistance) { %>'
  span class: 'distance-direct', "{{ directDistance }} km"
  if not options?.leaveOpen
    text '<% } %>'

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


# Menu page -template
script type: 'text/template', id: 'menu-page', ->
  header 'data-role': 'header', ->
    h1 'Menu'
  div 'data-role': 'content', ->
    ul 'data-role': 'listview', 'data-inset': 'true', 'data-theme': 'a', 'data-dividertheme': 'a', ->
      li 'data-role': 'list-divider', ->
        'Find gas near you'
      li ->
        a href:'#map'
          'Map view'
      li ->
        a href:'#list'
          'List view'
      li 'data-role': 'list-divider', ->
        'Settings'
      li ->
        a href:'#settings', 'data-transition':'slide', ->
          'User settings'
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
    div id: 'small-map-canvas'
    h2 '{{ street }}'
    h3 '{{ zip }} {{ city }}'
    h3 class: 'distance', ->
      conditionalStationDistance()

    div id: 'prices'

    div id: "addOtherPrice", 'data-role': "fieldcontain", ->
      label for: 'otherType', 'Other fuel types:'
      fuelTypeSelect()

    input id: 'saveButton', type: 'submit', value: 'Save'

    div class: 'commentarea', 'data-role': 'collapsible', 'data-theme': 'b', 'data-content-theme': 'e', ->
      h3 'Comments (comment count)'
      div class: 'comment', ->
        table ->
          tr ->
            td class: 'comment-title', ->
              h4 'Comment title'
            td class: 'comment-author', ->
              'Comment author'
          tr ->
            td class: 'comment-content', ->
              'Comment content'
  gasofooter ->
    partial 'navigation'



# Stations list page -template
script type: 'text/template', id: 'list-page', ->
  header 'data-role': 'header', ->
    h1 'Stations listed'
  div 'data-role': 'content', ->
    fieldset id: 'fueltypes', class: "ui-grid-c", ->
      div class: "ui-block-a", -> button 'data-fueltype': '95E10', 'data-mini': 'true', '95'
      div class: "ui-block-b", -> button 'data-fueltype': '98E5', 'data-mini': 'true', '98'
      div class: "ui-block-c", -> button 'data-fueltype': 'Diesel', 'data-mini': 'true', 'Di'
      div class: "ui-block-d", -> fuelTypeSelect firstOptionLabel: 'Other:'
      # TODO button for other fuel types
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

# Price-edit for station-details form
script type: 'text/template', id: 'price-edit', ->
  text '<% if (typeof value === "undefined") { value = ""; } %>'
  text '<% ptype = "price"+type; %>'

  label for: "{{ptype}}", "{{type}}"
  input class: 'price-input', type: "text", name: "{{ptype}}", id: "{{ptype}}", value: "{{value}}", placeholder: "Price of {{type}}"



# Stations-list list-item
script type: 'text/template', id: 'station-list-item', ->
  a 'href' : '#stations/{{ osmId }}/refuel', ->
      # TODO set some generic image if brand is not set?
    text '<% if (!brand) { brand = "question"; } %>'
    img src: "../images/stationlogos/{{ brand }}_100.png"
    # alternative approach:
    # span class: 'ui-icon ui-icon-station ui-icon-{{ brand }}'

    # TODO Improve price rendering, it is a bit clumsy to have this much logic here in the template?
    text '<% _ftype = Gaso.app.router.user.get("myFuelType"); %>'
    text '<% _priceToDisplay = _.find(prices, function(p) {return p.type === _ftype}).value %>'
    text '<% if (_priceToDisplay != null) { _priceToDisplay = _ftype + ": " + _priceToDisplay + " &euro;" } %>'
    h1 class: 'price', '{{ _priceToDisplay }}'
    
    p class: "station-info", ->
      span '{{ name }}'
      text '<% if (street && city) { %>'
      span '{{ street }}, {{ city }}'
      text '<% } %>'

    div class: "ui-li-aside distance-col", ->
      h2 class: 'distance', ->
        conditionalStationDistance leaveOpen: true
        text '<% } else { %>'
        text 'N/A'
        text '<% } %>'
