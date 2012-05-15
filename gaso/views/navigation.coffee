# Navigation bar
div 'data-role': 'navbar', ->
  ul id: 'navigation', ->
    li ->
      a 'href': '#search', 'Find'
    li ->
      a 'href': '#map', 'Map'
    li ->
      a 'href': '#list', 'List'
    li ->
      a 'href': '#menu', 'Menu'
