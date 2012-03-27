# Main script for initializations etc.
$doc = $ document

# Disable JQM routing and use Backbone routing instead
$doc.bind 'mobileinit', (event) ->
  $.mobile.ajaxEnabled = false
  $.mobile.linkBindingEnabled = false
  $.mobile.hashListeningEnabled = false
  $.mobile.pushStateEnabled = false

  # Remove page from DOM when it's being replaced
  $doc.on 'pagehide', 'div[data-role="page"]', (event) ->
    $(@).remove
    return

  return

  # Here we could probably also e.g. open & initialize socket.io sockets or smth       