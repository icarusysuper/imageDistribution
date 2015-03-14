proxy      = require '../proxy'
User       = proxy.User
Album      = proxy.Album
validator  = require 'validator'
Eventproxy = require 'eventproxy'
bbCrypto   = require '../helper/bbCrypto'

userMiddleware = require './user'

exports.signup = (req, res, next)->
    phone_number = validator.trim(req.body.phone_number) || ''
    password     = validator.trim(req.body.password)     || ''
    re_password  = validator.trim(req.body.re_password)  || ''
    relation     = validator.trim(req.body.relation)     || ''
    jpush_registration_id = req.body.jpush_registration_id

    if ([phone_number, password, re_password, relation].some (value)-> value is '')
        return next {status: 422, error: '信息不完整'}

    if password isnt re_password
        return next {status: 422, error: '两次输入的密码不一致'}

    ep = new Eventproxy()
    ep.fail next

    User.findOne {phone_number}, ep.done('gotUser')

    ep.once 'gotUser', (user)->
        if user then return next {status: 422, error: '这个电话号码已经被注册了'}
        password = bbCrypto.encodePassword password

        docs = {phone_number, password, jpush_registration_id}
        User.insert docs, ep.done('newUserDone')

    ep.once 'newUserDone', (user)->
        docs = 
            followers: {}
        docs.followers[relation] = 
            id: user._id.toHexString()
            phone_number: user.phone_number
            is_creator: true
        Album.insert docs, ep.done('newAlbumDone', (album)-> {album, user})

    ep.once 'newAlbumDone', (data)->
        data.user.album = 
            id: data.album._id.toHexString()
            relation: relation 
        data.user.save ep.doneLater('updateUserDone')
            
    ep.once 'updateUserDone', (user)->
        res.json 
            flag: true


exports.signin = (req, res, next)->
    phone_number          = validator.trim(req.body.phone_number)
    password              = bbCrypto.encodePassword validator.trim(req.body.password)
    jpush_registration_id = req.body.jpush_registration_id

    ep = new Eventproxy()
    ep.fail next

    User.findOne {phone_number}, ep.done('gotUser')

    ep.once 'gotUser', (user)->
        if not user then return next {error: '没有这个用户'}
        if password isnt user.password then return next {error: '密码错误'}

        if jpush_registration_id and jpush_registration_id isnt user.jpush_registration_id
            user.jpush_registration_id = jpush_registration_id
            user.save ep.doneLater('authDone')
        else ep.emitLater('authDone', user)

    ep.once 'authDone', (user)->
        req.session.user = user

        ep.emitLater 'loadUser', user
        userMiddleware.loadAlbumData user.album.id, ep.done('loadAlbum')
        userMiddleware.loadPhotosDataByAlbumId user.album.id, ep.done('loadPhotos')

    ep.all 'loadUser', 'loadAlbum', 'loadPhotos', (user, album, photos)->
        res.json
            flag: true
            session_id: req.sessionID
            user: User.getUserPersonalInfo user
            album: album
            photos: photos

exports.signout = (req, res, next)->
    req.session.destroy (err)->
        if err then return next err
        console.log 'session destroy'
        res.json {flag: true}

# 第三方登录


