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

  # Tryigng to get rid of flickering between page transitions.
  # However, flickering still seems to be an issue even with this fix. :/ --Markus
  # See e.g. https://github.com/jquery/jquery-mobile/issues/455
  if navigator.userAgent.match /iPhone|iPad|iPod/i
    $ '<link/>',
      rel   : 'stylesheet'
      # text  : '.ui-page {-webkit-backface-visibility: hidden !important;}'
      # Trying to set style for body instead of .ui-page, any luck?
      text  : 'body {-webkit-backface-visibility: hidden !important;}'
    .appendTo 'head'


