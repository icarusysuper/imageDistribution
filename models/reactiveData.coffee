mongoose = require 'mongoose'
Schema = mongoose.Schema

# type is 0 means data(photo or album) need to be updated by client
# type is 1 means data(etags) need to be deleted by client
reactiveDataSchema = new Schema
    data: {type: Schema.Types.Mixed, default: ""}
    type: {type: Number, default: 0}
    to: {type: [String], default: []}
    create_at: {type: Date, default: Date.now()}
, versionKey: false

mongoose.model 'ReactiveData', reactiveDataSchema