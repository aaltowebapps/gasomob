###
User
###
class window.User extends Backbone.Model
  urlRoot: 'user'
  noIoBind: true
  settings: {}


  myOptions: {
    center: new google.maps.LatLng(60.167, 24.955),
    zoom: 14,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }
