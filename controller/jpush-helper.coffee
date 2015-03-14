JPush    = require 'jpush-sdk'
config   = require '../config'

class JPushHelper
    constructor: (@appKey, @masterSecret)->
        @instance = null

    init: ()->
        JPush.buildClient @appKey, @masterSecret

    getJPushClient: ()->
        if not @instance then return @instance = @init()
        @instance

    # @param {[String]} to
    # @param {Object} notification
        # notification {
        #     title: String
        #     content: String
        #     extras: {
        #         sth: sth
        #         ...
        #     }
        # }
    # @param {Object} option
        # option {
        #     sendno: sth
        #     time_to_live: sth
        #     override_msg: sth
        #     apns_production: sth
        #     big_push_druation: sth
        # }
    # @param {function} callback
    sendNotification: (to, notification, option, callback)->
        if not callback 
            callback = option
            option = {
                sendno: null
                time_to_live: 86400 * 3
                override_msg_id: null
                # apns_production: null
                # big_push_duration: null
            }

        to = @validTo to
        if not to then return callback null, {msg: '没有要通知的人'}

        client = @getJPushClient()
        client.push().setPlatform('android')
            .setAudience(JPush.registration_id to)
            .setNotification(JPush.android notification.content, notification.title, 1, notification.extras)
            .setOptions(option.sendno, option.time_to_live, option.override_msg_id)
            .send callback

    validTo: (to)->
        if typeof to is 'string' then return to

        newTo = []
        if typeof to is 'object'
            for id in to 
                if id and typeof id is 'string' then newTo.push id
        if newTo.length is 0 then return false
        newTo


module.exports = new JPushHelper config.jpush.app_key, config.jpush.master_secret
