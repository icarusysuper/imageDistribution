router   = require('express').Router()
album    = require '../controller/album'
user     = require '../controller/user'

router.use user.checkSignin

router.get '/search?', album.searchAblum

router.post '/new_follow', album.newFollow

router.get '/process_follow/:followId?', album.processFollow

module.exports = router
