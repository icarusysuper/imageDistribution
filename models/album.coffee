mongoose = require 'mongoose'
Schema = mongoose.Schema

AlbumSchema = new Schema
    album_name: {type: String, default: '宝宝相册'}
    followers: Schema.Types.Mixed
    create_at: {type: Date, default: Date.now()}
, versionKey: false


# followers: {
#     father: {
#         id: String
#         phone_number: String
#         is_creator: Boolean
#     }
#     mother: {
#         id: String
#         phone_number: String
#         is_creator: Boolean
#     }
# }


# AlbumSchema.methods.addCreatorToFollowers = ()->
#     @followers.push @creator
#     @save()

mongoose.model 'Album', AlbumSchema
