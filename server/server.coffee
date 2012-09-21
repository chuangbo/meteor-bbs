# server


Meteor.methods
  login:  (email, password, token) ->
    this.unblock()
    Meteor.http.post(
      "https://dnsapi.cn/User.Detail",
      {params:
        login_email: email
        login_password: password
        login_code: token
        login_remember: 'yes'
        lang: 'cn'
        format: 'json'
      }
    )

Meteor.startup ->
  # code to run on server at startup
