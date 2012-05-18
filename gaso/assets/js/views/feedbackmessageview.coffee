class Gaso.FeedbackMessage extends Backbone.View

  timers = []
  messageCount = 0
  messagesParent = 'body'
  containerId    = 'messages'
  defaults =
    lifetime : 5
    replace  : false

  constructor: (@msg, options) ->
    @settings = _.extend {}, defaults, options
    # @template = _.template Gaso.util.getTemplate 'feedback-message'
    @setElement $('<div class="feedback" style="display: none;" />')

  render: (eventName) ->
    # Not needing a template for now, just using plain text content.
    # tmplData =
    #   msg: @msg
    #   options: @settings 
    # @$el.html @template tmplData
    @renderContainer()
    @renderMessage()
    return @

  renderContainer: ->
    @clearMessages() if @settings.replace
    @getMessagesContainer().fadeIn() unless messageCount
    
  renderMessage: ->
    messageCount++
    @$el.text @msg
    @$el.prependTo @getMessagesContainer()
    @$el.fadeIn()
    # Note: delayedRemove can't be fadeIn callback, else "too early" clearMessages() won't remove the timer for this message.
    @delayedRemove()

  close: =>
    @off()
    @remove()

  delayedRemove: =>
    if @settings.lifetime
      timer = setTimeout =>
        messageCount--
        @$el.fadeOut @close
        @getMessagesContainer().fadeOut() unless messageCount
        timers = _.without timers, timer
      , @settings.lifetime * 1000
      timers.push timer

  getMessagesContainer: ->
    $msgs = $ "##{containerId}"
    unless $msgs.length
      tpl = _.template Gaso.util.getTemplate 'feedback-message-container'
      $msgs = $ tpl()
      console.log $msgs.html(), 
      $msgs.hide()
      $msgs.appendTo messagesParent
    return $msgs

  clearMessages: ->
    for t in timers
      clearTimeout t
    timers = []
    @getMessagesContainer().empty()
    messageCount = 0
