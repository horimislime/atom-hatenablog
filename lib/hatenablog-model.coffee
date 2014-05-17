https = require 'https'
request = require 'request'
moment = require 'moment'
_ = require 'underscore'

module.exports =
class HatenaBlog
  constructor: ->
      @isPublic = null
      @description = ""
      @entryBody = ""

  getHatenaId: ->
    atom.config.get("atom-hatenablog.hatenaId")

  getBlogId: ->
    atom.config.get("atom-hatenablog.blogId")

  getApiToken: ->
    atom.config.get("atom-hatenablog.apiToken")

  post: (callback) ->
    draftStatus = if @isPublic then 'no' else 'yes'

    requestBody = """
      <?xml version="1.0" encoding="utf-8"?>
      <entry xmlns="http://www.w3.org/2005/Atom"
             xmlns:app="http://www.w3.org/2007/app">
        <title>#{@description}</title>
        <author><name>#{@getHatenaId()}</name></author>
        <content type="text/plain">
          #{_.escape(@entryBody)}
        </content>
        <updated>#{moment().format('YYYY-MM-DDTHH:mm:ss')}</updated>
        <app:control>
          <app:draft>#{draftStatus}</app:draft>
        </app:control>
      </entry>
    """
    
    options =
      hostname: 'blog.hatena.ne.jp'
      path: "/#{@getHatenaId()}/#{@getBlogId()}/atom/entry"
      auth: "#{@getHatenaId()}:#{@getApiToken()}"
      method: 'POST'
      headers:
          'Content-Length': Buffer.byteLength(requestBody, 'utf-8')

    request = https.request options, (res) ->
      res.setEncoding "utf8"
      body = ''
      res.on "data", (chunk) ->
        body += chunk
      res.on "end", ->
        callback(body)

    request.write requestBody
    request.end()
