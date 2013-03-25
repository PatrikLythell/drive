express = require 'express'
jade = require 'jade'
google = require './reader'
config = require './config'
portfolio = require './portfolio'
db = require('mongojs').connect('mongodb://nodejitsu:51f55075e421154ed2175960e3756675@linus.mongohq.com:10072/nodejitsudb4055495529', ['users'])

google.config(config.google)

app = express()

# CONFIGURATION

app.configure ->
  app.set 'view engine', 'jade'
  app.set 'views', "#{__dirname}/views"
  app.set 'port', process.env.PORT || 3000

  app.use express.bodyParser()
  app.use express.static(__dirname + '/public')
  app.use express.cookieParser()
  app.use express.session
    secret : "shhhhhhhhhhhhhh!"
  #app.use express.logger()
  app.use express.methodOverride()
  app.use app.router

app.configure 'development', () ->
  app.use express.errorHandler
    dumpExceptions: true
    showStack     : true

app.configure 'production', () ->
  app.use express.errorHandler()

# ROUTES

app.get '/', (req, res) ->
  
  portfolio.sync null, null, (resp) ->
    console.log resp

  ###
  google.listFiles null, (resp) ->
    portfolio.create resp, (arr) ->
      console.log arr

  
    for item in resp.items
      if item.file and item.file.parents and item.file.parents[0]
        console.log item.file if item.file.parents[0].id is '0BwF9Jd0AjOqgcVNtVlNrV3hweVE'
      # if item.file.parents and item.file.parents[0].id
        # item.file.parents # 
  
  google.listFiles null, (resp) ->
    portfolio.create resp, (arr) ->
      console.log arr
  ###

  res.render 'index',
    title: 'Hello World!'
      
app.get '/auth', (req, res) ->
  google.auth (resp) ->
    res.redirect(resp)

app.get '/oauth2callback', (req, res) ->
  google.getToken req.query.code, (resp) ->
    req.session.google = resp
    res.redirect('/pick-name')

app.get '/pick-name', (req, res) ->
  res.render 'username' 


# SERVER
  
app.listen(app.get('port'))
console.log "Express server listening on port #{ app.get 'port' }"