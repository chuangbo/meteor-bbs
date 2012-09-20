(($) -> #jQuery cookie
  $.cookie = (key, value, options) ->
    if arguments.length > 1 and (not /Object/.test(Object::toString.call(value)) or value is null or value is undefined)
      options = $.extend({}, options)
      options.expires = -1  if value is null or value is undefined
      if typeof options.expires is "number"
        days = options.expires
        t = options.expires = new Date()
        t.setDate t.getDate() + days
      value = String(value)
      return (document.cookie = [ encodeURIComponent(key), "=", (if options.raw then value else encodeURIComponent(value)), (if options.expires then "; expires=" + options.expires.toUTCString() else ""), (if options.path then "; path=" + options.path else ""), (if options.domain then "; domain=" + options.domain else ""), (if options.secure then "; secure" else "") ].join(""))
    options = value or {}
    decode = (if options.raw then (s) -> s else decodeURIComponent)
    pairs = document.cookie.split("; ")
    i = 0
    pair = undefined
    while pair = pairs[i] and pairs[i].split("=")
      return decode(pair[1] or "")  if decode(pair[0]) is key
      i++
    null
) jQuery

Topics = new Meteor.Collection 'topics'
Replys = new Meteor.Collection 'replys'
Members = new Meteor.Collection 'members'
Nodes = new Meteor.Collection 'nodes'
