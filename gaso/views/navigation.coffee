# Navigation bar
div 'data-role': 'navbar', ->
  ul ->
    li ->
      a 'href': '#search', 'data-icon': 'search', 'Find'
    li ->
      a 'href': '#map', 'data-icon': 'home', 'Map'
    li ->
      a 'href': '#list', 'data-icon': 'grid', 'List'
    li ->
      a 'href': '#menu', 'data-icon': 'home', 'Menu'
