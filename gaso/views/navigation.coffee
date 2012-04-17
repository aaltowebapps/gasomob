# Navigation bar
div 'data-role': 'navbar', ->
  ul ->
    li ->
      a 'href': '#refuel', 'data-icon': 'drop', 'Fuel up!'
    li ->
      a 'href': '#map', 'data-icon': 'home', 'Map'
    li ->
      a 'href': '#list', 'data-icon': 'grid', 'Stations'
    li ->
      a 'href': '#settings', 'data-icon': 'gear', 'Settings'
