###
usersettingsview.coffee
###
class Gaso.UserSettingsPage extends Backbone.View
  events:
    'change' : 'saveChanges'

  constructor: (@user) ->
    @template = _.template Gaso.util.getTemplate 'user-settings-page'
    @setElement $('<div id="page-user-settings"/>')

  render: (eventName) ->
    $(@el).html @template @user.toJSON()
    @initializeInputs()
    return @
  
  close: =>
    @off()
    #@user.off ...

  # Initialize inputs from user properties
  initializeInputs: ->
    @initInput elem for elem in @.$(':input')

  initInput: (input) ->
    $(input).val @user.get(input.name)

  setUserProperty: (property, value) =>
    # Set only properties that already exist in user attributes.
    @user.set property, value if @user.get(property)?

  saveChanges: =>
    Gaso.log "Save new settings"
    @setUserProperty elem.name, elem.value for elem in @.$(':input')
    @user.save()
