AlbumModel = require('../models').Album
Collection = require './collection'

class Album extends Collection
    # insert: (docs, callback)->
    #     super docs, (err, album)->
    #         if err then next err
    #         album.addCreatorToFollowers()
    #         callback?()

module.exports = new Album AlbumModel
