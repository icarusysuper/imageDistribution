# base on mongoose
class Collection
    constructor: (@collection)->

    insert: (docs, callback)->
        newDocs = new @collection docs
        newDocs.save callback

    remove: (condition, callback)->
        @collection.remove condition, callback

    # @param {object} condition
    # @param {string} field (optional fields to select, like '_id username')
    # @param {object} option (like $skip, $sort, ..., { lean: true })
    # @param {function} callback
    find: (condition, field, option, callback)->
        @collection.find condition, field, option, callback

    findOne: (condition, field, option, callback)->
        @collection.findOne condition, field, option, callback

    # @param {object} update
    update: (condition, update, option, callback)->
        @collection.update condition, update, option, callback

    count: (condition, callback)->
        @collection.count condition, callback

module.exports = Collection
