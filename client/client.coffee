# init

Session.set 'view', null
Session.set 'topic_id', null
Session.set 'tab', '/'
Session.set 'memberId', null
Session.set 'page', 1

PAGE_ITEM = 20




# all nodes
Meteor.subscribe 'all_nodes'

# current page topics
Meteor.autosubscribe ->
  Meteor.subscribe "topics", Session.get('tab'), Session.get('page')

# current page reply
Meteor.autosubscribe ->
  Meteor.subscribe "replys", Session.get('topic_id')

# client: declare collection to hold count object
Meteor.subscribe 'pages_count'

# FIXME: subscribe all user profile
Meteor.subscribe 'allUserData'

# FIXME
# subscribe member's topic & replys
# Meteor.autosubscribe ->
#   Meteor.subscribe 'member_topics', Session.get('memberId')
# Meteor.autosubscribe ->
#   Meteor.subscribe 'member_replys', Session.get 'memberId'


# staff
logined = ->
  Meteor.user()


showerror = (message) ->
  $('.problem li').html message
  $('.problem').show()



formData = (form) ->
  data = {}
  for i in $(form).serializeArray()
    data[i.name] = i.value
  data

userof = (userId) ->
  Meteor.users.findOne({_id: userId})?.profile.name



# view helpers

view_helpers =

  all_nodes: ->
    Nodes.find()

  node_name: (key) ->
    Nodes.findOne(name: key)?.zh

  userof: userof

  user: ->
    userof this.userId

  gravatar: (size) ->
    profile = Meteor.users.findOne({'_id': this.userId})?.profile
    if size <= 30
      profile?.figureUrl
    else if size <= 50
      profile?.figureUrlAt50
    else
      profile?.figureUrlAt100

  fromnow: (t) ->
    moment.utc(t).fromNow()

  content: ->
    ct = this.content
    for parser in content_parser
      ct = parser ct
    ct

  no_reply: ->
    this.reply_count == 0


content_parser = [
  # escape
  (o) -> Handlebars._escape o
  # br
  (o) -> o.replace /\n/g, '<br>'
  # mention
  (o) -> o.replace /@([a-zA-z0-9]+)/g, '<a href="/member/$1">@$1</a>'
  # linkify
  (o) -> o.replace /(http|https|ftp)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(:[a-zA-Z0-9]*)?\/?([a-zA-Z0-9\-\._\?\,\'\/\\\+&amp;%\$#\=~])*/g, '<a href="$&" target="_blank">$&</a>'
  # gist
  # (o) -> o.replace /(https?:\/\/gist.github.com\/[\d]+)/g, '<script src="$1.js"></script>'
]


# main
# Template.main.events
#   'click a:not([href^="http"]):not([href^="#"])': (e) ->
#     e.preventDefault()
#     href = $(e.currentTarget).attr 'href'
#     Router.navigate href, {trigger: true}





# right bar

Template.rightbar.helpers view_helpers

Template.rightbar.helpers
  logined: ->
    Meteor.user()
  member: ->
    Meteor.user()

Template.rightbar.preserve ['img']

Template.rightbar.events
  'click #loginBtn': =>
    Meteor.loginWithQq()



# index
Template.index.helpers view_helpers

Template.index.helpers
  topics: ->

    # tab
    tab = Session.get 'tab'

    sel = if tab == '/' then {} else {nodes: tab}
    r = Topics.find sel, {sort: {updated: -1}}

    r.fetch().slice 0, PAGE_ITEM

  current_tab: (node) ->
    node == Session.get 'tab'

  next_page: ->
    page = Session.get('page') - 0 + 1
    tab = Session.get 'tab'

    if tab == '/'
      "/p#{page}"
    else
      "/go/#{tab}/p#{page}"

  prev_page: ->
    page = Session.get('page') - 1
    tab = Session.get 'tab'

    if tab == '/'
      "/p#{page}"
    else
      "/go/#{tab}/p#{page}"

  current_page: ->
    Session.get('page')

  page_count: ->
    tab = Session.get 'tab'
    Pages.findOne(tab: tab)?.count

  has_prev_page: ->
    Session.get('page')-0 != 1

  has_next_page: ->
    tab = Session.get 'tab'
    max_page = Pages.findOne(tab: tab)?.count

    max_page != 0 and Session.get('page')-0 != max_page

Template.index.rendered = ->
  Meteor.call 'updatePagesCount', Session.get('tab')

# topic item line
Template.topic_item.helpers view_helpers
Template.topic_item.preserve ['img']






# new topic
Template.new.helpers view_helpers

Template.new.helpers
  default_node: (name) ->
    tab = if (tab = Session.get('tab')) == '/' then 'dnspod' else tab
    'checked' if name == tab

Template.new.events
  'submit form': (e) ->
    e.preventDefault()

    data = formData e.currentTarget
    data.userId = Meteor.userId()
    data.created = new Date()
    data.updated = new Date()
    data.reply_count = 0
    data.views = 0

    delete data.node
    data.nodes = []

    $('input[name="node"]:checked').each ->
      data.nodes.push $(this).val()

    if data.title == ''
      showerror '主题标题不能为空'
      return

    if data.nodes.length > 3
      showerror '一个主题只能发布在最多3个节点下'
      return

    topic_id = Topics.insert data

    Meteor.Router.to "/t/#{topic_id}#reply0"






# one topic
Template.topic.helpers view_helpers
Template.topic.helpers
  topic: ->
    topic_id = Session.get 'topic_id'
    Topics.update {_id: topic_id}, {$inc: {views: 1}}
    Topics.find _id: topic_id

  replys: ->
    r = Replys.find(topic_id: this._id).fetch()
    _i = 1
    for i in r
      i.index = _i
      _i += 1
    r
  logined: logined

Template.topic.events
  'submit form': (e) ->
    e.preventDefault()

    data = formData e.currentTarget
    data.topic_id = this._id
    data.userId = Meteor.userId()
    data.created = new Date()


    if data.content == ''
      showerror '回复内容不能为空'
      return

    Replys.insert data

    # update topic last_reply & replys
    Topics.update {_id: this._id},
      {
        $set: {last_reply: Meteor.userId(), updated: new Date()}
        $inc: {reply_count: 1}
      }

    reply_count = Topics.findOne(_id: this._id).reply_count
    Meteor.Router.to "/t/#{this._id}#reply#{reply_count}"

    $('#content').val('')

  "click .ReplyOne": (e) ->
    e.preventDefault()

    i = $('#content')
    old = i.val()

    prefix = "@#{userof this.userId} "

    i.focus()
    if old.length > 0 and old != prefix
      i.val "#{old}\n#{prefix}"
    else
      i.val prefix

# reply
Template.reply.helpers view_helpers
Template.reply.preserve ['img']




# member
Template.member.helpers view_helpers

Template.member.helpers
  member: ->
    Meteor.users.find '_id': Session.get 'memberId'

  topics: ->
    r = Topics.find {userId: this._id}, {sort: {updated: -1}}
    r.fetch().slice 0, 20

  replys: ->
    r = Replys.find {userId: this._id}, {sort: {created: -1}}
    r.fetch().slice 0, 20

  reply_to: (topic_id) ->
    Topics.find _id: topic_id


# APP


Meteor.Router.add
  '/': ->
    Session.set 'tab', '/'
    Cookie.set 'tab', '/'
    Session.set 'page', 1
    'index'
  '/p:page': (page) ->
    Session.set 'tab', '/'
    Cookie.set 'tab', '/'
    Session.set 'page', page
    'index'
  '/new': ->
    if not logined()
      return
    else
      'new'
  '/login': ->
    if logined()
      this.navigate '/', {trigger: true}
    else
      'login'
  '/t/:topic_id': (topic_id) ->
    topic_id = topic_id.split('#', 2)[0]
    Session.set 'topic_id', topic_id
    'topic'
  '/go/:node': (node) ->
    Session.set 'tab', node
    Cookie.set 'tab', node
    Session.set 'page', 1
    'index'
  "/go/:node/p:page": (node, page) ->
    Session.set 'tab', node
    Cookie.set 'tab', node
    Session.set 'page', page
    'index'
  "/member/:id": (id) ->
    Session.set 'memberId', id
    'member'

Meteor.Router.filters
  'checkLoggedIn': (page) ->
    if Meteor.user()
      if Meteor.user()
        'loading'
      else
        page
    else
      'signin'

Meteor.startup ->
  tab = Cookie.get 'tab'

  if location.pathname == '/' and tab? and tab != '/'
    Meteor.Router.to "/go/#{tab}"




