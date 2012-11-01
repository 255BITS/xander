express = require('express')
fs = require('fs')
giles = require 'giles'
journal = require '../../lib/journal'
connect = require 'connect'
path = require 'path'
RedisStore = require('connect-redis')(connect)

app = module.exports = express.createServer()

port = 4400

app.configure( () ->
  app.set 'views', __dirname + '/../../public'
  app.set 'view engine', 'jade'
  app.set('view options', { layout: false })
  app.use(express.cookieParser())
  app.use(express.session({ store: new RedisStore(), secret: "ideas are a dime a dozen.  we will need 120 to make a dollar" }))
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(app.router)
)

app.configure('development', -> 
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))
  giles.locals.environment = 'development'
  giles.locals.development =  true
  app.use(giles.connect(__dirname + '/public'))
)

app.configure('test', ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))
  app.use(giles.connect(__dirname + '/public'))
  port = 14400
)

app.configure('production', () ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))
  app.use(express.static(path.join(__dirname, 'public')))
)

app.get '/heartbeat', (req, res) ->
  res.send("ok")


app.listen(port, ->
  console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env)
)
