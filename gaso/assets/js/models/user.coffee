###
User
###
class Gaso.User extends Backbone.Model
  id: 'localUser'
  #noIoBind: true
  localStorage: new Backbone.LocalStorage("Gaso.User")


  defaults: 
    mapSettings:
      # Current point of interest.
      poi:
        lat: 60.167
        lon: 24.955
      zoom: 14
      mapTypeId: 'ROADMAP'


  getGoogleMapSettings: ->
    stngs = @get('mapSettings')

    # return object in google.maps options format
    center: new google.maps.LatLng(stngs.poi.lat, stngs.poi.lon)
    zoom: stngs.zoom
    mapTypeId: google.maps.MapTypeId[stngs.mapTypeId]

