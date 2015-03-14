router   = require('express').Router()
user     = require '../controller/user'

router.get '/search?', user.searchUser

router.get '/update_session', user.updateSession

router.get '/load_all_data', user.loadAllData

router.get '/load_all_new_data', user.loadAllNewData

router.get '/load_spec_new_data', user.loadSpecNewData

module.exports = router
