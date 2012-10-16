# server


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
