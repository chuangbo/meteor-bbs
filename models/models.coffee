Topics = new Meteor.Collection 'topics'
Replys = new Meteor.Collection 'replys'
Nodes = new Meteor.Collection 'nodes'

simpleAcl = 
  insert: (userId, doc) ->
    userId and doc.userId is userId
  update: (userId, docs, fields, modifier) ->
    for field in ['_id', 'userId', 'content', 'created', 'nodes', 'title']
      return false if field in fields
    true
  remove: (userId, doc) ->
    false

Topics.allow simpleAcl
Replys.allow simpleAcl

Nodes.allow
  insert: ->
    true
  update: ->
    false
  remove: ->
    false
