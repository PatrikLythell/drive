express = require 'express'
jade = require 'jade'
google = require './reader'
config = require './config'
portfolio = require './portfolio'

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



  google.listFiles null, (resp) ->
    portfolio.create resp, (arr) ->
      console.log arr
    

  res.render 'index',
    title: 'Hello World!'
      
app.get '/auth', (req, res) ->
  google.auth (resp) ->
    res.redirect(resp)

app.get '/oauth2callback', (req, res) ->
  google.getToken req.query.code, (resp) ->
    console.log(resp)
    res.end()


# SERVER
  
app.listen(app.get('port'))
console.log "Express server listening on port #{ app.get 'port' }"