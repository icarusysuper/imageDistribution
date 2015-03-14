{User, Album, Photo, Follow} = require '../proxy'

_           = require 'underscore'
Eventproxy  = require 'eventproxy'

JPushHelper = require './jpush-helper'

getRelationInChinese = 
informUser = 
checkRelationIsVaild = 
updateUserAndMergeAlbum =
updatePhotosInAlbumB = 
null

exports.searchAblum = (req, res, next)->
	query = req.query.q || ''
	condition = 
		album_name: query.trim() # 改进。正则，模糊搜索。
	Album.find condition, (err, result)->
		if err then return next err
		res.json 
			flag: true
			result: result

exports.newFollow = (req, res, next)->
	{album_id, album_creator_id} = req.body
	user = req.session.user

	ep = new Eventproxy()
	ep.fail next

	checkRelationIsVaild album_id, user.album.relation, ep.doneLater('relationIsValid') 

	ep.once 'relationIsValid', ()->
		docs = 
			state: 'processing'
			album: 
				id: album_id
				creator_id: album_creator_id
			from: 
				id: user._id
				phone_number: user.phone_number
				relation: user.album.relation

		Follow.insert docs, ep.done('saveDone')

	ep.once 'saveDone', (followDocs)->
		content = getRelationInChinese(followDocs.from.relation) + "(电话号码为：#{followDocs.from.phone_number}), 申请共享相册"
		extras = 
			follow_id: followDocs._id.toHexString()
			type: 'follow_request'

		informUser album_creator_id, content, extras, ep.doneLater('informDone')

	ep.once 'informDone', (jpushRes)->
		if not jpushRes then res.json {flag: false, message: '发送失败'}
		res.json
			flag: true
			message: '请等待对方同意'


exports.processFollow = (req, res, next)->
	_id = req.params.followId
	state = req.query.state?.toString().toLowerCase()
	
	if state isnt 'agree' and state isnt 'reject' then return next {error: 'state参数错误', status: 400} # 400 means bad request
	
	user = req.session.user

	ep = new Eventproxy()
	ep.fail next

	Follow.findOne {_id}, ep.done('gotFollow')

	ep.once 'gotFollow', (follow)->
		if not follow then return next {error: '没有这个关系', status: 403}
		if follow.state isnt 'processing' then return next {error: '异常的followId', status: 403}

		follow.state = state
		follow.save ep.doneLater('updateFollowDone')

	ep.once 'updateFollowDone', (follow)->
		if state is 'agree'
			updateUserAndMergeAlbum follow, ep.doneLater('agreeFollowThenUpdateAndMergeDone', ()-> follow.from.id)
		else 
			ep.emitLater('rejectFollow', follow.from.id)
		
	ep.any 'rejectFollow', 'agreeFollowThenUpdateAndMergeDone', (stateEvent)->
		proposerId = stateEvent.data
		content = getRelationInChinese(user.relation) + "(电话号码为：#{user.phone_number})" +
			(if state is 'agree' then '同意' else '拒绝') + "共享相册"
		extras = 
			state: state
			type: 'follow_result'
		informUser proposerId, content, extras, ep.doneLater('informDone') 

	ep.once 'informDone', (jpushRes)->
		if not jpushRes then res.json {flag: false, message: '发送失败'}
		res.json 
			flag: true

# consider transaction in future
updateUserAndMergeAlbum = (follow, callback)->
	ep = new Eventproxy()
	ep.fail callback

	User.findOne {_id: follow.from.id}, ep.done('gotUserB')

	ep.once 'gotUserB', (userB)->
		albumBId = userB.album.id
		albumAId = follow.album.id

		updatePhotosInAlbumB albumBId, albumAId, ep.doneLater('updatePhotosInAlbumBDone', ()-> albumBId)

		userB.album.id = albumAId
		userB.save ep.done('updateUserBDone')

	ep.all 'updatePhotosInAlbumBDone', 'updateUserBDone', (albumBId, userB)->
		Album.remove {_id: albumBId}, ep.doneLater('deleteAblumBDone', ()-> userB)

	newFollower = 
		id: follow.from.id
		phone_number: follow.from.phone_number
		is_creator: false

	Album.findOne {_id: follow.album.id}, (err, album)->
		if err then return callback err
		if not album then return callback {status: 403, error: '没有该相册'}

		# Mongoose doesn't create getters/setters for array indexes
		album.set "followers.#{follow.from.relation}", newFollower
		album.save ep.doneLater('updateAlbumADone')

	ep.all 'deleteAblumBDone', 'updateAlbumADone', (userB, albumA)->
		callback null

updatePhotosInAlbumB = (albumBId, albumAId, callback)->
	Photo.update {'identity.album_id': albumBId}, $set: {'identity.album_id': albumAId}, callback


checkRelationIsVaild = (albumId, proposerRelation, callback)->
	ep = new Eventproxy()
	ep.fail callback

	Album.findOne {_id: albumId}, ep.done('gotAlbum')

	ep.once 'gotAlbum', (album)->
		if not album then return callback {error: '没有该相册', status: 403}
		if _.has album.followers, proposerRelation 
			callback {error: '相册已有' + getRelationInChinese(proposerRelation), status: 403}
		else 
			callback null

informUser = (toId, content, extras, callback)->
	ep = new Eventproxy()
	ep.fail callback

	User.findOne {_id: toId}, ep.done('gotUser')

	ep.once 'gotUser', (user)->
		to = if user.jpush_registration_id then [user.jpush_registration_id] else callbak(null, false)
		notification = 
			title: '宝宝相册'
			content: content
			extras: extras
		JPushHelper.sendNotification to, notification, callback

getRelationInChinese = (relation)->
		if relation is 'father'
			'爸爸'
		else if relation is 'mother'
			'妈妈'
		else
			'其他'
