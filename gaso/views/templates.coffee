# Format Coffeekup's html-output to human-readable form with indents and line breaks.
@.format = true

# NOTE! If you update templates, update the 'templatesversion' in layout.coffee
# TODO some automatic system for template version detection?


# Map page -template
div id: 'map-page', ->
  #header 'data-role': 'header', ->
  #  h1 'Map'
  div 'data-role': 'content', ->
    div id: 'map-canvas'
    partial 'navigation'


# User settings page -template
div id: 'user-settings-page', ->
  header 'data-role': 'header'


# Stations list template
div id: 'list-page', ->
  header 'data-role': 'header', ->
  	h1 'E10 near you'