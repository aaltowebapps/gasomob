# Main script for initializations etc.
$d = $ document

# Disable JQM routing and use Backbone routing instead
$d.bind 'mobileinit', (event) ->
  console.log 'mobileinit'
  $.mobile.ajaxEnabled = false
  $.mobile.linkBindingEnabled = false
  $.mobile.hashListeningEnabled = false
  $.mobile.pushStateEnabled = false
  return

  # Remove page from DOM when it's being replaced
  $d.on 'pagehide', 'div[data-role="page"]', (event) ->
    $(this).remove
    return

  
  # Here we could probably also e.g. open & initialize socket.io sockets or smth       