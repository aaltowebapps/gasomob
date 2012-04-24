# Main script for initializations etc.
$doc = $ document

# Disable JQM routing and use Backbone routing instead
$doc.bind 'mobileinit', (event) ->
  _.extend $.mobile,
    ajaxEnabled          : false
    linkBindingEnabled   : false
    hashListeningEnabled : false
    pushStateEnabled     : false


