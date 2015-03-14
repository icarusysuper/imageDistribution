require 'date-utils'
config = require './config'
path = require 'path'
User = require('./proxy').User
Album = require('./proxy').Album
crypto = require './helper/bbCrypto'
config = require './config'
mongoose = require 'mongoose'

user = 
    phone_number: 'bb007'
	password: crypto.encrypt 'bb007', config.pass_crypto_secret

User.count (err, count)->
	if err then throw err
	if count is 0
		User.insert user

album = 
    creator: {
        id: new mongoose.Types.ObjectId
        relation: 'father'
    }
    album_name: 'bb007'

Album.count (err, count)->
    if err then throw err
    if count is 0
        Album.insert album
