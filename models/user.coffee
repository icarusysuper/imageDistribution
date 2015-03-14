mongoose     = require 'mongoose'
Schema       = mongoose.Schema
config       = require '../config'

UserSchema = new Schema
    phone_number: {type: String, unique: true}
    password: String
    jpush_registration_id: {type: String, default: ""}
    album: {
        id: String
        relation: String
    }
    create_at: {type: Date, default: Date.now()}
, versionKey: false

mongoose.model 'User', UserSchema
