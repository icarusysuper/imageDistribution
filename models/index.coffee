mongoose = require 'mongoose'
config = require '../config'
env = process.env.NODE_ENV || 'development'

console.log 'execute env is ' + env

options = {
    server: {
        auto_reconnect: true
    }
    replset: {}
}

options.server.socketOptions = options.replset.socketOptions = { keepAlive: 1 }
uri = config[env].uri

console.log 'database uri:', uri

mongoose.connect uri, options

# mongoose.connect('mongodb://username:password@host:port/database?options...');
# The server option auto_reconnect is defaulted to true which can be overridden. 
db = mongoose.connection
# db.on 'error', console.error.bind console, 'database connection error :-('
db.on 'error', (err)->
    console.error 'database connection error :-('
    mongoose.disconnect()

db.on 'disconnected', ()->
    console.log 'database has disconnected :-('

db.on 'connected', ()->
    console.log 'database has connected :-)'

db.once 'open', ()->
    console.log 'database has opened :-)'

db.on 'reconnected', ()->
    console.log 'database has reconnected :-)'

require './user'
require './album'
require './photo'
require './follow'
require './reactiveData'

exports.User    = mongoose.model 'User'
exports.Album   = mongoose.model 'Album'
exports.Photo   = mongoose.model 'Photo'
exports.Follow  = mongoose.model 'Follow'
exports.ReactiveData = mongoose.model 'ReactiveData'