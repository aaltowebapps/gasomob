# Main script for initializations etc.
$doc = $ document

# Disable JQM routing and use Backbone routing instead
$doc.bind 'mobileinit', (event) ->
  _.extend $.mobile,
    ajaxEnabled          : false
    linkBindingEnabled   : false
    hashListeningEnabled : false
    pushStateEnabled     : false

  # For phonegap
  # $.mobile.allowCrossDomainPages = true
  # $.support.cors = true

  # Get rid of flickering between page transitions.
  # See e.g. https://github.com/jquery/jquery-mobile/issues/455
  if navigator.userAgent.match /iPhone|iPad|iPod/i
    $ '<link/>',
      text  : '.ui-page {-webkit-backface-visibility: hidden;}'
    .appendTo 'head'


