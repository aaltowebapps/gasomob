# Main script for initializations etc.
$doc = $ document

# Disable JQM routing and use Backbone routing instead
$doc.bind 'mobileinit', (event) ->
  _.extend $.mobile,
    ajaxEnabled: false
    linkBindingEnabled: false
    hashListeningEnabled: false
    pushStateEnabled: false

  # Remove page from DOM when it's being replaced
  $doc.on 'pagehide', 'div[data-role="page"]', (event) ->
    console.log "Remove page", @
    $(@).remove()
    return

  return

  # Here we could probably also e.g. open & initialize socket.io sockets or smth       