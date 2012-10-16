Topics = new Meteor.Collection 'topics'
Replys = new Meteor.Collection 'replys'
Nodes = new Meteor.Collection 'nodes'

simpleAcl = 
  insert: ->
    true
  update: ->
    true
  remove: (userId, doc) ->
    userId is doc.userId

Topics.allow simpleAcl
Replys.allow simpleAcl
Nodes.allow simpleAcl
