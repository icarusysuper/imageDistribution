models = require '../models'
FollowModel = models.Follow
Collection = require './collection'

class Follow extends Collection

module.exports = new Follow FollowModel
