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
  selOpts =
    id: 'otherType'
    name: 'otherType'
  if options?.mini
    selOpts['data-mini'] = true
  select selOpts, ->
    option value: '', firstOptionLabel
    option 'data-fueltype': 'E85', value: 'E85', 'E85'
    option 'data-fueltype': 'Unleaded', value: 'Unleaded', 'Unleaded'

conditionalStationDistance = (options) ->
  text '<% if (drivingDistance) { %>'
  span class: 'distance-drive', "{{ drivingDistance }} km"
  text '<% } else if (directDistance) { %>'
  span class: 'distance-direct', "{{ directDistance }} km"
  if not options?.leaveOpen
    text '<% } %>'

flipSwitch = (options, text) ->
  return unless options?.for
  id = options.id or options.for
  div 'data-role': "fieldcontain", ->
    label for: id, text
    select id: id, name: options.for, 'data-role': "slider", 'data-theme': "a", ->
      option value: "", 'No'
      option value: "yes", 'Yes'

###
  PAGE TEMPLATES
###

# Map page -template
script type: 'text/template', id: 'map-page', ->
  div 'data-role': 'content', ->
    div id: 'map-canvas'
    div id: 'map-buttons', ->
      a href: '#', id: 'center-user', 'data-role': 'button', 'class': 'ui-shadow ui-icon ui-icon-centermap', 'data-iconpos': 'notext', 'Center on location'
      # button type: 'button', id: 'center-user', 'data-role': 'button', 'class': 'ui-icon ui-icon-centermap'
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
  div 'data-role': 'content', 'data-theme': 'c', ->
    # Note: Use directly to property name in user model for 'for' option.
    flipSwitch for: 'useSpecialTransitions', 'Use special transitions between pages'
    flipSwitch for: 'useSwipeToGoBack', 'Allow swipe for Back-navigation'
  gasofooter ->
    partial 'navigation'


# Search page
script type: 'text/template', id: 'search-page', ->
  header 'data-role': 'header', ->
    h1 'Station search'
  div 'data-role': 'content', ->
    form id: 'searchform', class: 'form ui-body-b ui-corner-all', ->
      # h2 'Please type in an address.'
      # div 'data-role': "fieldcontain", ->
      h2 'Find stations'
      input 'type': 'search', 'name': 'field-address', 'id': 'field-address', 'placeholder': 'Search for address, place, ...'
      button id: 'address-search', type: 'button', 'GO!'
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

    div class: 'clear'
    div 'data-role': 'collapsible-set', ->
      div 'data-role': 'collapsible', 'data-collapsed': 'false', ->
        h3 'I just filled my tank'
        div 'data-role': "fieldcontain", ->
          label for: 'refuel-amt', placeholder: 'Total amount', 'Amount'
          input id: 'refuel-amt', name: 'refuel-amt', type: 'number', placeholder: 'Amount of {{ curuser.myFuelType }} refueled'
        div 'data-role': "fieldcontain", ->
          label for: 'refuel-price', placeholder: 'Total price', 'Price'
          input id: 'refuel-price', name: 'refuel-price', type: 'number', placeholder: 'Total price'


      div 'data-role': 'collapsible', 'data-collapsed': 'true', ->
        h3 'I only want to update the prices'
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
      div class: "ui-block-d", -> fuelTypeSelect firstOptionLabel: 'Other:', mini: true
      # TODO button for other fuel types
    # jQM Listview for station list items
    ul id: 'list-stations', 'data-role': 'listview', 'data-dividertheme': 'c', 'data-split-theme': 'c', 'data-filter': 'true', ->
      # li id: 'stations-nearby', 'data-role': 'list-divider', 'Stations nearby'
      # List items will be added using 'station-list-item'-template
    # Slider for affecting stations searching/ranking.
    # TODO change filter to partial and include it into map page also?
  gasofooter ->
    div id: 'ranking-slider', 'data-role': 'fieldcontain', class: 'ui-bar ui-bar-c', ->
      div class : 'slidericon money', ->
        img src: 'images/euro.png', alt: '&euro;'
      div id: 'filterslider', ->
        input 'type':'range', 'name':'slider', 'id':'money-vs-distance', 'value':'25', 'min':'0', 'max':'100', 'data-theme':'b'
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
        textarea id: 'newcomment', name: 'newcomment', placeholder: 'Your review or comment...'
        button 'type': 'submit', 'data-inline': 'true', 'Shout!'
        # a 'href': '#', 'data-role': 'button', 'data-inline': 'true', 'Shout!'
    hr ->
    ul id: 'list-comments'


script type: 'text/template', id: 'feedback-message-container', ->
  div id: 'messages', class: 'ui-corner-all ui-shadow'


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
    text '<% if (_priceToDisplay) { _priceToDisplay = parseFloat(_priceToDisplay.value).toFixed(3); } %>'
    p class: 'station-info station-info-price', ->
      text '<% if ( _priceToDisplay && !isNaN(_priceToDisplay) ) { %>'
      span class: 'currency', '&euro;' 
      span class: 'price-value', '{{ _priceToDisplay }}'
      span class: 'fuel-type', '{{ "(" + _ftype + ")" }}'
      text '<% } %>'


###
  OTHER / PARTIALS
###

# Price-edit for station-details form
script type: 'text/template', id: 'price-edit', ->
  text '<% if (typeof value === "undefined") { value = ""; } %>'
  text '<% ptype = "price"+type; %>'

  text '<% if (typeof date !== "undefined") { %>'
  div class: 'timeago-info', ->
    span 'Updated '
    time class: 'timeago', 'datetime': '{{ date }}', '{{ date }}'
  text '<% } %>'

  label for: "{{ptype}}", ->
    span class: 'fueltype', "{{type}}"

  input class: 'price-input', type: "number", name: "{{ptype}}", id: "{{ptype}}", value: "{{value}}", placeholder: "Price of {{type}}"


# Online users display
script type: 'text/template', id: 'online-users', ->
  div id: 'online-users', 'data-theme': 'a', ->
    span class: 'ui-icon-person'
    span class: 'user-count', '{{ allUsersCount }}'
