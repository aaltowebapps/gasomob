class Gaso.OnlineUsersView extends Backbone.View
  
  containerId = 'online-users'

  events:
    'tap #online-users' : 'showMessage'

  initialize: ->
    @template = _.template Gaso.util.getTemplate 'online-users'
    @bindEvents()


  render: (eventName) ->
    tplObj =
      allUsersCount : @collection.allUsersCount
    @$el.html @template tplObj
    @$el.appendTo 'body' unless $("##{containerId}").length
    return @

  bindEvents: ->
    @collection.on 'change:allUsersCount', @onUsersCountChanged

  close: =>
    @off()
    @collection.off 'change:allUsersCount', @onUsersCountChanged


  onUsersCountChanged: (count) =>
    console.log "count change", count
    @render()

  showMessage: ->
    count = @collection.allUsersCount
    switch count
      when 0 then msg = ''
      when 1 then msg = "You're all alone! Recommend Gaso to your friends."
      else msg = "There are #{count} users online. Great!"

    Gaso.helper.message msg if msg
