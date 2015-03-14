router   = require('express').Router()
sign     = require '../controller/sign'

router.post '/signup', sign.signup

router.post '/signin', sign.signin

router.get '/signout', sign.signout

module.exports = router
