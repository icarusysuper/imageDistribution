models = require '../models'
PhotoModel = models.Photo
Collection = require './collection'

class Photo extends Collection

module.exports = new Photo PhotoModel
