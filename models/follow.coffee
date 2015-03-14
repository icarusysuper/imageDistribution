mongoose = require 'mongoose'
Schema = mongoose.Schema

FollowSchema = new Schema
    state: String
    album: {
        id: String
        name: String
        creator_id: String
    }
    from: {
        id: String
        phone_number: String
        relation: String
    }

    create_at: {type: Date, default: Date.now()}
, versionKey: false

mongoose.model 'Follow', FollowSchema
