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


# Stations list template
div id: 'list-page', ->
  header 'data-role': 'header', ->
    h1 'E10 near you'
  div 'data-role': 'content', ->
    ul 'data-role': 'listview', 'data-split-theme': 'b', 'data-filter': true, ->
      # Dummy list items
      li ->
        a 'href':'#', ->
          img src:'images/stationlogos/abc_100.png'
          h2 ->       
            '1,234'
          h3 ->
            'Station 1'
          p class:'ui-li-aside distance', ->
            "10 km"
      li ->
        a 'href':'#', ->
          img src:'images/stationlogos/st1_100.png'
          h2 ->       
            '1,234'
          h3 ->
            'Station 2'
          p class:'ui-li-aside distance', ->
            "20 km"
    div 'data-role':'fieldcontain', 'id':'slider', 'class':'ui-bar', 'class':'ui-bar-d', ->
      table ->
        tr ->
          td class:'slidericon', ->
            img src:'images/euro.png', alt:'€'
          td ->
            form id:'filterslider', ->
            input 'type':'range', 'name':'slider', 'id':'slider-0', 'value':'25', 'min':'0', 'max':'100', 'data-theme':'b'
          td class:'slidericon', ->
            img src:'images/distance.png', alt:'km'
  partial 'navigation'