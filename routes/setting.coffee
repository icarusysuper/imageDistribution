router   = require('express').Router()
setting  = require '../controller/setting'
user     = require '../controller/user'

router.use user.checkSignin

router.post '/change_password', setting.changePassword

router.post '/change_album_name', setting.changeAlbumName

module.exports = router
