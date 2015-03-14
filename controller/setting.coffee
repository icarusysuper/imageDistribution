{User, Album} = require '../proxy'

bbCrypto      = require '../helper/bbCrypto'

validator     = require 'validator'
Eventproxy    = require 'eventproxy'

exports.changePassword = (req, res, next)->
    _id = req.session.user._id # _id in session is a string

    old_password = bbCrypto.encodePassword validator.trim req.body.old_password
    new_password = bbCrypto.encodePassword validator.trim req.body.new_password
    
    ep = new Eventproxy()
    ep.fail next

    User.findOne {_id}, ep.doneLater('gotUser')

    ep.once 'gotUser', (user)->
        if not user then return next {msg: '用户不存在'}
        if old_password isnt user.password then return next {msg: '原密码错误'}

        user.password = new_password
        user.save ep.doneLater('saveDone')

    ep.once 'saveDone', (uesr)->
        req.session.user = user
        res.json {flag: true}

hasPermissionToChangeAlbumName = null
exports.changeAlbumName = (req, res, next)->
    _id = req.session.user.album.id

    new_album_name = validator.trim req.body.new_album_name

    ep = new Eventproxy()
    ep.fail next

    Album.findOne {_id}, ep.doneLater('gotAlbum')

    ep.once 'gotAlbum', (album)->
        if not album then return next {error: '您没有相册'}

        album.album_name = new_album_name
        album.save ep.doneLater('saveDone')

    ep.once 'saveDone', (album)->
        res.json 
            flag: true
