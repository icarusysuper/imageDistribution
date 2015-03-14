express       = require 'express'
path          = require 'path'
logger        = require 'morgan'
cookieParser  = require 'cookie-parser'
bodyParser    = require 'body-parser'
session       = require 'express-session'
MongoStore    = require('connect-mongo')(session)
multer        = require 'multer'

routes        = require './routes'

app = express()

config = require('./config')[app.get 'env']

app.use logger('dev')

app.use bodyParser.json()
app.use bodyParser.urlencoded extended: true

app.use multer
    dest: './upload_files_cache/'

app.use cookieParser config.cookie_secret

app.use session
    name: config.cookie_name
    secret: config.cookie_secret
    resave: false
    saveUninitialized: false
    store: new MongoStore 
        db: config.db_name
        host: config.db_host
        port: config.db_port

app.use express.static path.join(__dirname, 'public')

for key, value of routes
    mountPath = '/' + key
    route = value
    app.use mountPath, route
# app.use '/', routes

# catch 404 and forward to error handler
app.use (req, res, next)->
    err = new Error 'Not Found'
    err.status = 404
    next err
    
# error handlers
app.use (err, req, res, next)->
    res.status err.status || 500
    res.json 
        flag: false
        error: err

# load fixture data in development environment
# if (app.get 'env') is 'development'
#     require './fixture'

module.exports = app;
