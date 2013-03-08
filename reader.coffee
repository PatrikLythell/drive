request = require 'request'

redirect_uri = ''
client_id = ''
client_secret = ''

authorization_code = true

url = 'https://accounts.google.com/o/oauth2/token'

apiBase = 'https://www.googleapis.com/drive/v2/files/'

hardToken = "ya29.AHES6ZTx_1KjFiSNACU9SZECXHhjJVFpU8M7GToY_7YRzQ"

module.exports =

  # CONFIGS

  config: (config) ->
    redirect_uri = config.redirect_uri
    client_id = config.client_id
    client_secret = config.client_secret
    return

  auth: (callback) ->
    auth_url = "https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/drive&access_type=offline&response_type=code&redirect_uri=#{ redirect_uri }&client_id=#{ client_id }"
    callback(auth_url)

  getToken: (reqToken, callback) ->
    params =
      "code": reqToken
      "client_id": client_id
      "client_secret": client_secret
      "redirect_uri": redirect_uri
      "grant_type": "authorization_code"
    request.post
      url: url
      form: params
    , (err, res, body) -> 
      throw err if err
      console.log res.statusCode
      if res.statusCode is 200 # IF 401 exchange refresh token for access token or just log user out and start over. Second might be safer
        callback(JSON.parse(body))
      else
        console.log "you're fucked by first one"
        #console.log res

  refresh: (token, callback) ->
    params = 
      client_secret: client_secret
      grant_type: "refresh_token"
      refresh_token: token
      client_id: client_id
    request.post
      url: "https://accounts.google.com/o/oauth2/token"
      form: params
    , (err, res, body) ->
      body = JSON.parse(body)
      callback(body.access_token)

  listFiles: (token, callback) ->
    request.get
      uri: apiBase
      headers:
        authorization: "Bearer #{hardToken}"
    , (err, res, body) ->
      getOurFOlder = (items) ->
        for item in items
          return item if item.mimeType is 'application/vnd.google-apps.folder' and item.title is 'Test'
      body = JSON.parse(body)
      body = getOurFOlder(body.items)
      unless err then callback(body) else console.log err

  getChildren: (token, folder, callback) ->
    request.get
      uri: apiBase+folder+'/children'
      headers:
        authorization: "Bearer #{hardToken}"
    , (err, res, body) ->
      unless err then callback(JSON.parse(body)) else console.log err

  getFile: (token, file, callback) ->
    request.get
      uri: apiBase+file
      headers:
        authorization: "Bearer #{hardToken}"
    , (err, res, body) ->
      unless err then callback(JSON.parse(body)) else console.log err