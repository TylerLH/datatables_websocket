# Modules
express = require 'express'
http = require 'http'
app = express()
server = http.createServer(app)
io = require('socket.io').listen(server)
_ = require('underscore')

# Boot setup
require("#{__dirname}/../config/boot")(app)

io.sockets.on 'connection', (client) =>
  timer = null
  client.on 'start', ->
    timer = setInterval ->
      batch = []

      for i in [0.._.random(0, 1000)]
        do ->
          batch.push {message: 'I love the internet. The internet is great.', timestamp: Date.now()}
      client.emit 'batch', batch: batch
    , 1000

  client.on 'stop', ->
    clearInterval(timer)

# Configuration
app.configure ->
  port = process.env.PORT || 3000
  if process.argv.indexOf('-p') >= 0
    port = process.argv[process.argv.indexOf('-p') + 1]

  app.set 'port', port
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'jade'
  app.use express.static("#{__dirname}/../public")
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use require('connect-assets')(src: "#{__dirname}/assets")
  app.use app.router

app.configure 'development', ->
  app.use express.errorHandler()

# Routes
require("#{__dirname}/routes")(app)

# Server
server.listen app.get('port'), ->
  console.log "Express server listening on port #{app.get 'port'} in #{app.settings.env} mode"
