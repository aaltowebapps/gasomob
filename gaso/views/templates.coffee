# Format Coffeekup's html-output to human-readable form with indents and line breaks.
@.format = true unless process.env.NODE_ENV is 'production'

# NOTE! If you update templates, update the 'templatesversion' in layout.coffee


# Map page -template
div id: 'map-page', ->
  #header 'data-role': 'header', ->
  #  h1 'Map'
  div 'data-role': 'content', ->
    div id: 'map-canvas'
  partial 'navigation'


# User settings page -template
div id: 'user-settings-page', ->
  header 'data-role': 'header', ->
    h1 'Settings'
  div 'data-role': 'content', ->
    # TODO content
  partial 'navigation'

# Station details page template
div id: 'station-details', ->
  header 'data-role': 'header', 'data-add-back-btn': true, ->
    h1 'Details'
  div 'data-role': 'content', ->
    h2 @name or 'Aseman nimi'
    p @address or 'Osoite 123, 00100 Helsinki'
    table ->
      tr ->
        td 'E10:'
        td ->
          input type: 'text', value: '0.00'
      tr ->
        td '98:'
        td ->
          input type: 'text', value: '0.00'
      tr ->
        td 'Diesel:'
        td ->
          input type: 'text', value: '0.00'
      tr ->
        td ''
        td ->
          input type: 'submit', value: 'Save'
    # TODO content

# Stations list template
div id: 'list-page', ->
  header 'data-role': 'header', ->
    h1 'E10 near you'
  div 'data-role': 'content', ->
    ul 'data-role': 'listview', 'data-split-theme': 'b', 'data-filter': true, ->
      # Dummy list items
      li ->
        a 'href':'#', ->
          h2 ->       
            '1,234'
          h3 ->
            'Station 1'
      li ->
        a 'href':'#', ->
          h2 ->       
            '1,234'
          h3 ->
            'Station 2'
    form ->
      input 'type':'range', 'name':'slider', 'id':'slider-0', 'value':'25', 'min':'0', 'max':'100'
  partial 'navigation'