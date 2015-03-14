{User, Album, Photo, ReactiveData} = require '../proxy'

validator  = require 'validator'
Eventproxy = require 'eventproxy'
_          = require 'underscore'

exports.checkSignin = (req, res, next)->
    if req.session.user then return next()

    res.json 
        flag: false
        error: {status: 403, message: '请先登录', redirect: 'signin'}

exports.searchUser = (req, res, next)->
    console.log 'hah'
    phone_number = validator.trim(req.query.q) || ''
    console.log phone_number
    User.findOne {phone_number}, (err, user)->
        console.log user
        if err then return next err
        res.json 
            flag: true
            result: User.getUserPersonalInfo user

loadUserData = (userId, callback)->
    User.findOne {_id: userId}, callback

loadAlbumData = (albumId, callback)->
    Album.findOne {_id: albumId}, callback

loadPhotosDataByAlbumId = (albumId, callback)->
    Photo.find {'identity.album_id': albumId}, callback

loadPhotosDataByUserId = (userId, callback)->
    Photo.find {'identity.user_id': userId}, callback

loadPhotosDataByAlbumIdAndUserId = (albumId, userId, callback)->
    Photo.find {'identity.album_id': albumId, 'identity.user_id': user_id}, callback

loadAllData = (req, res, next)->
    ep = new Eventproxy()
    ep.fail next

    userId = req.session.user._id

    loadUserData userId, ep.done('gotUser')

    ep.once 'gotUser', (user)->
        if not user then return next {status: 403, error: '加载用户数据异常，不存在的用户。'}
        
        ep.emitLater 'loadUser', user
        loadAlbumData user.album.id, ep.done('loadAlbum')
        loadPhotosDataByAlbumId user.album.id, ep.done('loadPhotos')

    ep.all 'loadUser', 'loadAlbum', 'loadPhotos', (user, album, photos)->
        res.json 
            flag: true
            user: user
            album: album
            photos: photos

exports.updateSession = (req, res, next)->
    if not req.session.user then return next {status: 403, error: '请先登录'}
    _id = req.session.user._id

    User.findOne {_id}, (err, user)->
        if err then return next err
        if not user then return next {status: 403, error: '不存在该用户，请重新登录'}

        req.session.user = user
        res.json
            flag: true
            user: User.getUserPersonalInfo user

getAllNewDataAndUpdateReactiveData = null
exports.loadAllNewData = (req, res, next)->
    if not req.session.user then return next {status: 403, error: '请先登录'}
    userId = req.session.user._id

    ep = new Eventproxy()
    ep.fail next

    ReactiveData.find({to: $all: [userId]}).sort('create_at').exec ep.done('gotData')

    ep.once 'gotData', (dataList)->
        getAllNewDataAndUpdateReactiveData dataList, userId, ep.done('processDataDone')

    ep.once 'processDataDone', (data)->
        res.json 
            flag: true
            data: data

getAllNewDataAndUpdateReactiveData = (dataList, userId, callback)->
    ep = new Eventproxy()
    ep.fail callback

    reactiveData = 
        dataToBeUpdated:
            album: null
            photos: []
        dataToBeDeleted:
            etags: []

    ep.after 'saveDataDone', dataList.length, (updatedDataList)->
        callback null, reactiveData

    for item in dataList
        {data, type} = item
        if type is 0
            if data.album then reactiveData.dataToBeUpdated.album = data.ablum
            if data.photos then reactiveData.dataToBeUpdated.photos = _.union reactiveData.dataToBeUpdated.photos, data.photos
        else if item.type is 1
            if item.data.etags then reactiveData.dataToBeDeleted.etags = _.union reactiveData.dataToBeDeleted.etags, data.etags
        item.to.pull userId
        item.save ep.doneLater('saveDataDone')

exports.loadSpecNewData = (req, res, next)->
    if not req.session.user then return next {status: 403, error: '请先登录'}
    userId = req.session.user._id

    reactiveDataId = req.query.reactive_data_id
    if not reactiveDataId then return next {status: 403, error: '缺少参数reactive_data_id'}

    ep = new Eventproxy()
    ep.fail next 

    ReactiveData.findOne {_id: reactiveDataId}, ep.done 'gotReactiveData', (reactiveData)-> 
        data = reactiveData.data
        reactiveData.to.pull userId
        reactiveData.save ep.done('gotReactiveData', (reactiveData)-> data)

    ep.once 'gotReactiveData', (data)->
        res.json
            flag: true
            data: data

exports.loadAllData = loadAllData

exports.loadUserData = loadUserData

exports.loadAlbumData = loadAlbumData

exports.loadPhotosDataByAlbumId = loadPhotosDataByAlbumId
exports.loadPhotosDataByUserId = loadPhotosDataByUserId
exports.loadPhotosDataByAlbumIdAndUserId = loadPhotosDataByAlbumIdAndUserId