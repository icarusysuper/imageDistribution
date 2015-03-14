UserModel = require('../models').User
Collection = require './collection'

class User extends Collection
    getUserPersonalInfo: (user)->
        if not user then return null
        return {
            _id: user._id.toHexString()
            phone_number: user.phone_number
            jpush_registration_id: user.jpush_registration_id
            album: user.album
            create_at: user.create_at
        }

    findOneAndUpdate: (condition, update, option, callback)->
        UserModel.findOneAndUpdate condition, update, option, callback        

module.exports = new User UserModel
