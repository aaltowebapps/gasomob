###
usersettingsview.coffee
###
class Gaso.UserSettingsPage extends Backbone.View
  constructor: (@user) ->
    @template = _.template Gaso.util.getTemplate 'user-settings-page'
    @setElement $('<div id="page-user-settings"/>')

  render: (eventName) ->
    $(@el).html @template @user.toJSON()
    return @
  
  close: =>
    @off()
    #@user.off ...
