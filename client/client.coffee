# init
Session.set 'view', null
Session.set 'email', null
Session.set 'topic_id', null
Session.set 'tab', '/'
Session.set 'member', null
Session.set 'page', 1

PAGE_ITEM = 20

gravatars = {}

window.init_bbs = ->
  NODES =
    dnspod: '闲聊'
    tech: '技术'
    web: 'Web'
    dns: 'DNS'
    python: 'Python'

  for k, v of NODES
    Nodes.insert name: k, zh: v



# staff
logined = ->
  Session.get('email')?


showerror = (message) ->
  $('.problem li').html message
  $('.problem').show()



formData = (form) ->
  data = {}
  for i in $(form).serializeArray()
    data[i.name] = i.value
  data

userof = (email) ->
  email.split('@', 2)[0]



# view helpers

view_helpers =

  all_nodes: ->
    Nodes.find()

  node_name: (key) ->
    Nodes.findOne(name: key)?.zh

  userof: userof

  user: ->
    userof this.email

  gravatar: (email, size) ->
    return Gravatar.imageUrl email, {s: size}
    key = "#{email}_#{size}"
    if key of gravatars
      gravatars[key]
    else
      gravatars[key] = "//www.gravatar.com/avatar/#{MD5 email}?s=#{size}"

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
  (o) -> _.escape o
  (o) -> o.replace /@([a-zA-z0-9]+)/g, '<a href="/member/$1">@$1</a>'
  (o) -> o.replace /\n/g, '<br>'
]


# main
Template.main.events
  'click a:not([href^="http"]):not([href^="#"])': (e) ->
    e.preventDefault()
    href = $(e.currentTarget).attr 'href'
    Router.navigate(href, true)





# right bar

Template.rightbar.helpers view_helpers

Template.rightbar.helpers
  # logined: -> Session.get('email')?
  # logined: -> false
  # logined: -> false
  logined: ->
    this.email?
  member: ->
    Members.findOne email: Session.get 'email'

Template.rightbar.preserve ['img']



# index
Template.index.helpers view_helpers

Template.index.helpers
  topics: ->

    # tab
    tab = Session.get 'tab'
    console.log 'get topics', tab

    sel = if tab == '/' then {} else {nodes: tab}
    r = Topics.find sel, {sort: {updated: -1}}

    # page
    # ugly here, because meteor do not support limit & skip
    start = PAGE_ITEM * (Session.get('page') - 1)
    end = start + PAGE_ITEM

    r.fetch().slice start, end

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
    sel = if tab == '/' then {} else {nodes: tab}
    Math.ceil ( Topics.find(sel).count() / PAGE_ITEM )

  has_prev_page: ->
    Session.get('page') - 0 != 1

  has_next_page: ->
    tab = Session.get 'tab'
    sel = if tab == '/' then {} else {nodes: tab}
    max_page = Math.ceil ( Topics.find(sel).count() / PAGE_ITEM )

    Session.get('page') - 0 != max_page


# topic item line
Template.topic_item.helpers view_helpers
Template.topic_item.preserve ['img']



# login
Template.login.events
  'submit form': (e) ->
    e.preventDefault()


    data = formData e.currentTarget

    if data.email == ''
      showerror '请输入用户名'
      return

    if data.password == ''
      showerror '请输入密码'
      return
    
    Meteor.call 'login', data.email, data.password, data.token, (error, result) ->
      r = JSON.parse result.content

      if r.status.code == '1'

        if r.info.user.is_staff != 'yes'
          showerror '请使用员工帐号登录'
          return
          
        Cookie.set 'cat', data.email
        Session.set 'email', data.email

        if not Members.findOne(email: data.email)?
          Members.insert
            email: data.email
            user: userof data.email
            created: new Date()

        Router.navigate '/', true
      else
        showerror r.status.message







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
    data.email = Session.get 'email'
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

    Router.navigate "t/#{topic_id}", true






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
    data.email = email = Session.get 'email'
    data.created = new Date()

    console.log data

    if data.content == ''
      showerror '回复内容不能为空'
      return

    Replys.insert data

    # update topic last_reply & replys
    Topics.update {_id: this._id},
      {
        $set: {last_reply: email, updated: new Date()}
        $inc: {reply_count: 1}
      }

    $('#content').val('')

  "click .ReplyOne": (e) ->
    e.preventDefault()

    i = $('#content')
    old = i.val()

    prefix = "@#{userof this.email} "

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
    Members.find user: Session.get 'member'

  topics: ->
    r = Topics.find {email: this.email}, {sort: {updated: -1}}
    r.fetch().slice 0, 20

  replys: ->
    r = Replys.find {email: this.email}, {sort: {created: -1}}
    r.fetch().slice 0, 20

  reply_to: (topic_id) ->
    Topics.find _id: topic_id


# APP


BbsRouter = ReactiveRouter.extend
  routes:
    "": "index"
    "p:page": "index_page"
    "login": "login"
    "new": "new"
    "t/:topic_id": "topic"
    "go/:node": "tab"
    "go/:node/p:page": "tab_page"
    "member/:user": "member"
  index: ->
    Session.set 'tab', '/'
    Cookie.set 'tab', '/'
    Session.set 'page', 1
    this.goto 'index'
  index_page: (page) ->
    Session.set 'tab', '/'
    Cookie.set 'tab', '/'
    Session.set 'page', page
    this.goto 'index'
  new: ->
    if not logined()
      this.navigate 'login', true
    else
      this.goto 'new'
  login: ->
    if logined()
      this.navigate '/', true
    else
      this.goto 'login'
  topic: (topic_id) ->
    topic_id = topic_id.split('#', 2)[0]
    Session.set 'topic_id', topic_id
    this.goto 'topic'
  tab: (node) ->
    Session.set 'tab', node
    Cookie.set 'tab', node
    Session.set 'page', 1
    this.goto 'index'
  tab_page: (node, page) ->
    Session.set 'tab', node
    Cookie.set 'tab', node
    Session.set 'page', page
    this.goto 'index'
  member: (member) ->
    Session.set 'member', member
    this.goto 'member'


Router = new BbsRouter

Meteor.startup ->
  console.log 'meteor startup'
  tab = Cookie.get 'tab'
  Session.set 'email', Cookie.get('cat')
  Backbone.history.start pushState: true

  if location.pathname == '/' and tab? and tab != '/'
    Router.navigate "go/#{tab}", true




