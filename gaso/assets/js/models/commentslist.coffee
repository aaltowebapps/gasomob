###
CommentsList
###
class Gaso.CommentsList extends Backbone.Collection
  model: Gaso.Comment
  url: 'comments'
  socket: window.socket