class Gaso.SearchContext extends Backbone.Model

  defaults:

    routeFrom:
      address: null
      lon: null
      lat: null
    routeTo: null

    searchAddress: null

    mapBounds:
      lon: null
      lat: null
