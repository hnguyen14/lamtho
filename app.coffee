express = require("express")
db = require './config/cradle'
routes = require("./routes")
app = module.exports = express.createServer()

Training = require './tools/training'
Poem = require './tools/poem'

# Configuration
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "coffee"
  app.register '.coffee', require('coffeekup').adapters.express
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + "/public")

app.configure "development", ->
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true


app.configure "production", ->
  app.use express.errorHandler()


# Routes
app.get "/", routes.index

app.get '/init', (req, res) ->
  Training.loadTraining (err) ->
    if err 
      res.send 'ERROR'
    else
      res.send 'SUCCESS'

app.get '/gen', (req, res) ->
  Poem.gen (poem) ->
    res.render 'poem', locals:
      poem: poem

app.listen 3001
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
