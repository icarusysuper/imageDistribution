router       = require('express').Router()
distribution = require '../controller/distribution'

user         = require '../controller/user' 
router.use user.checkSignin

router.get '/uptoken', distribution.getUptoken

router.post '/upload_done', distribution.savePhotosThenPushMessage

router.post '/download_urls', distribution.getDownloadUrls

router.post '/delete_photos', distribution.deletePhotos

module.exports = router
