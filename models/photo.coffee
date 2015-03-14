mongoose = require 'mongoose'
Schema = mongoose.Schema

PhotoSchema = new Schema
    identity: {
        user_id: String
        album_id: String
        relation: String
    }
    etag: String
    # photograph_location: {
    #     longitude: String
    #     latitude: String
    #     place: String
    # }
    photograph_location : {type: Schema.Types.Mixed, default: ""}
    photograph_time: {type: String, default: ""}
    like_by: {type: [String], default: []}
    is_deleted: {type: Boolean, default: false}
    create_at: {type: Date, default: Date.now()}
, versionKey: false

mongoose.model 'Photo', PhotoSchema
