###
Comment
###
class Gaso.Comment extends Backbone.Model

  defaults:
    content: ''
    publishDate: ''
    title: ''
    userId: ''

  initialize: (data) ->
    @set 'userId', data.by if data.by?
