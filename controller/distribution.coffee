qiniuHelper    = require './qiniu-helper'
JPushHelper    = require './jpush-helper'
config         = require '../config'

{User, Album, Photo, ReactiveData} = require '../proxy'

Eventproxy     = require 'eventproxy'
validator      = require 'validator'
_              = require 'underscore'

exports.getUptoken = (req, res, next)->
    bucketname = config.qiniu.bucketname
    res.json
        flag: true
        uptoken: qiniuHelper.getUptoken bucketname

exports.getDownloadUrls = (req, res, next)->
    reqPhotoParams = JSON.parse(req.body.reqPhotoParams) || []
    if not _.isArray reqPhotoParams then return next {status: 403, error: 'reqPhotoParams参数错误'} 
    
    res.json
        flag: true
        downloadUrls: qiniuHelper.generateDownloadUrls reqPhotoParams

savePhotos = 
pushMessage = 
findFollowers = null
exports.savePhotosThenPushMessage = (req, res, next)->
    user   = req.session.user
    # photos: [photo]
    # photo: etag, photograph_location, photograph_time
    photos = (JSON.parse req.body.photos) || [] 
    if photos.length is 0 then return next {status: 422, error: '没有照片'}

    ep = new Eventproxy()
    ep.fail next

    savePhotos user, photos, ep.done('savePhotosDone')

    ep.once 'savePhotosDone', (photos)->
        ep.emitLater 'gotPhotos', photos
        findFollowers user, ep.done('gotFollowers')

    ep.all 'gotPhotos', 'gotFollowers', (photos, toUserIds)->
        docs = 
            data: 
                photos: photos
            to: toUserIds
        ReactiveData.insert docs, ep.done('insertReactiveDataDone')

    ep.all 'gotFollowers', 'insertReactiveDataDone', (toUserIds, reactiveData)->
        pushMessage user, toUserIds, reactiveData, ep.done('pushMsgDone')

    ep.once 'pushMsgDone', (jpushRes)->
        res.json
            flag: true

savePhotos = (user, photos, callback)->
    identity = 
        user_id: user._id # get from express-session
        album_id: user.album.id
        relation: user.album.relation

    ep = new Eventproxy()
    ep.fail callback

    ep.after 'insertPhotosDone', photos.length, (photoList)->
        callback null, photoList

    for photo in photos
        {etag, photograph_location, photograph_time} = photo
        docs = {identity, etag, photograph_location, photograph_time}

        Photo.insert docs, ep.group('insertPhotosDone')

pushMessage = (sender, toUserIds, reactiveData, callback)->
    ep = new Eventproxy()
    ep.fail callback

    User.find {_id: $in: toUserIds}, ep.done('gotUsers')

    ep.once 'gotUsers', (users)->
        to = []
        to.push user.jpush_registration_id for user in users
        content = "#{sender.album.relation}分享了#{reactiveData.data.photos.length}宝宝照片"
        notification = 
            title: "宝宝相册"
            content: content
            extras: 
                reactive_data_id: reactiveData._id.toHexString()
                type: 'new_photo'

        JPushHelper.sendNotification to, notification, callback

findFollowers = (sender, callback)->
    ep = new Eventproxy()
    ep.fail callback

    Album.findOne {_id: sender.album.id}, ep.done('gotAlbum')

    ep.once 'gotAlbum', (album)->
        ids = []
        followers = _.omit album.followers, sender.album.relation
        for relation of followers
            ids.push followers[relation].id

        callback null, ids

removePhotosInReactiveData = 
markPhotoDeleted = null
exports.deletePhotos = (req, res, next)->
    user   = req.session.user
    etags = (JSON.parse req.body.etags) || [] 
    if etags.length is 0
        res.json
            flag: true

    ep = new Eventproxy()
    ep.fail next

    markPhotoDeleted etags, ep.done('markDone')

    ep.once 'markDone', ()->
        findFollowers user, ep.done('gotFollowers')

    ep.once 'gotFollowers', (toUserIds)->
        docs = 
            data: 
                etags: etags
            to: toUserIds
            type: 1
        ReactiveData.insert docs, ep.done('insertReactiveDataDone') 

    ep.once 'insertReactiveDataDone', (data)->
        res.json
            flag: true

markPhotoDeleted = (etags, callback)->
    ep = new Eventproxy()
    ep.fail callback

    ep.after 'markDeleted', etags.length, ()->
        callback null

    for etag in etags
        Photo.update {etag}, $set: {is_deleted: true}, ep.done('markDeleted')
