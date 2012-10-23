# server
Meteor.methods
  migrateQQAvatar: ->
    for user in Meteor.users.find().fetch()
      path = user.profile.figureUrl.replace /^(.*)\/30$/, '$1'
      Meteor.users.update({_id: user._id}, {$set:{"profile.figureUrlAt50": "#{path}/50", "profile.figureUrlAt100": "#{path}/100"}})


Meteor.startup ->
  NODES =
    dnspod: '闲聊'
    tech: '技术'
    web: 'Web'
    dns: 'DNS'
    python: 'Python'

  if Nodes.find({}).count() is 0
    for k, v of NODES
      Nodes.insert name: k, zh: v
