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
  div 'data-role': 'content', ->
    div id: 'map-canvas'
    div id: 'map-buttons', ->
      a href: '#', 'data-role': 'button', 'data-icon': 'centermap', 'data-iconpos': 'notext', 'Center on location'
  gasofooter ->
    partial 'navigation'

# Single station map page -template
script type: 'text/template', id: 'station-map-page', ->
  header 'data-role': 'header', ->
    h1 '{{ name }}'
  div 'data-role': 'content', ->
    div id: 'station-map-canvas'
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


# Search page
script type: 'text/template', id: 'search-page', ->
  header 'data-role': 'header', ->
    h1 'Station search'
  div 'data-role': 'content', ->
    form class: 'ui-body-b', ->
      h2 'Please type in an address.'
      label 'for': 'search', 'Find stations near'
      input 'type': 'search', 'name': 'address', 'id': 'field-address'
      button 'type': 'submit', 'GO!'
  gasofooter ->
    partial 'navigation'


# Station details page -template
script type: 'text/template', id: 'station-details', ->
  header 'data-role': 'header', ->
    h1 '{{ name }}'
  div 'data-role': 'content', ->
    div id: 'small-map-canvas'

    h3 ->
      conditionalStationDistance()
      span class: 'address', ->
        text '<% if (address.street && address.city) { %>'
        text '{{ address.street }}, {{ address.city }}'
        text '<% } %>'

    div id: 'prices'

    div id: "addOtherPrice", 'data-role': "fieldcontain", ->
      label for: 'otherType', 'Other fuel types:'
      fuelTypeSelect()

    input id: 'saveButton', type: 'submit', value: 'Save'

    div id: 'comments'
      
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
      # li id: 'stations-nearby', 'data-role': 'list-divider', 'Stations nearby'
      # List items will be added using 'station-list-item'-template
    # Slider for affecting stations searching/ranking.
    # TODO change filter to partial and include it into map page also?
  gasofooter ->
    div id: 'ranking-slider', 'data-role': 'fieldcontain', class: 'ui-bar ui-bar-c', ->
      div class : 'slidericon money', ->
        img src: 'images/euro.png', alt: '&euro;'
      div id: 'filterslider', ->
        input 'type':'range', 'name':'slider', 'id':'slider-0', 'value':'25', 'min':'0', 'max':'100', 'data-theme':'b'
      div class : 'slidericon distance', ->
        img src:'images/distance.png', alt: 'km'
    partial 'navigation'


###
  COLLECTION TEMPLATES
###

script type: 'text/template', id: 'comments-list', ->
  div class: 'commentarea', 'data-role': 'collapsible', 'data-theme': 'a', 'data-content-theme': 'a', ->
    h3 'Comments'
    
    div 'data-role': 'fieldcontain', ->
      form ->
        label 'for': 'newcomment', 'id': 'ownid', ->
          '{{ curuser.id }}: '
        input 'type': 'text', 'name': 'newcomment', 'value': 'Your review'
        button 'type': 'submit', 'data-inline': 'true', 'Shout!'
        # a 'href': '#', 'data-role': 'button', 'data-inline': 'true', 'Shout!'
    hr ->
    ul id: 'list-comments'


###
  MODEL TEMPLATES
###


# Station comment
script type: 'text/template', id: 'comment-list-item', ->
  h4 class: 'comment-title', ->
    '{{ title }}'
  p class: 'comment-author', ->
    '{{ userId }}'
  p class: 'comment-publish-date', ->
    time class: 'timeago', 'datetime': '{{ date }}', '{{ date }}'
  p class: 'comment-content', -> 
    '{{ body }}'

# Price-edit for station-details form
script type: 'text/template', id: 'price-edit', ->
  text '<% if (typeof value === "undefined") { value = ""; } %>'
  text '<% ptype = "price"+type; %>'

  label for: "{{ptype}}", "{{type}}"
  input class: 'price-input', type: "number", min: "0.001", name: "{{ptype}}", id: "{{ptype}}", value: "{{value}}", placeholder: "Price of {{type}}"



# Stations-list list-item
script type: 'text/template', id: 'station-list-item', ->
  a 'href' : '#stations/{{ osmId }}/refuel', ->
    text '<% if (!brand) { brand = "question"; } %>'
    #img src: "../images/stationlogos/{{ brand }}_100.png"
    # alternative approach:
    span class: 'ui-icon ui-icon-station ui-icon-{{ brand }}'
    
    p class: "station-info station-info-name", ->
      span '{{ name }}'
      
    p class: "station-info station-info-address", ->
      text '<% if (address.street && address.city) { %>'
      span ' {{ address.street }}, {{ address.city }}'
      text '<% } %>'

    div class: 'clear'
    
    p class: "station-info station-info-distance", ->
      conditionalStationDistance leaveOpen: true
      text '<% } else { %>'
      text 'N/A'
      text '<% } %>'
      
    # TODO Improve price rendering, it is a bit clumsy to have this much logic here in the template
    text '<% _ftype = Gaso.app.router.user.get("myFuelType"); %>'
    text '<% _priceToDisplay = _.find(prices, function(p) {return p.type === _ftype}); %>'
    text '<% if (_priceToDisplay) { _priceToDisplay = _priceToDisplay.value; } %>'
    p class: 'station-info station-info-price', ->
      text '<% if (_priceToDisplay) { %>'
      span class: 'currency', '&euro;' 
      span class: 'price-value', '{{ _priceToDisplay }}'
      span class: 'fuel-type', '{{ "(" + _ftype + ")" }}'
      text '<% } %>'
