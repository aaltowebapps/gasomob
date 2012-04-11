###
usersettingsview.coffee
###
class UserSettingsPage extends Backbone.View
  @model: User

  initialize: ->
    @template = _.template Gaso.util.getTemplate 'user-settings'

  render: (eventName) ->
    $(@el).html @template @model.toJSON()
    return @
  