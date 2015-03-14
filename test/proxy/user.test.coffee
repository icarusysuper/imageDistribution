assert = require 'assert'
should = require 'should'
User = require '../../proxy/user'

userModel = require('../../models').User

describe 'proxy User unit test: ', ()->

    mockUserDoc = 
        username: 'luzhuoquan'
        password: 'luzhuoquan'
        phone_number: 'luzhuoquan'

    beforeEach (done)->
        user = new userModel mockUserDoc
        user.save done

    afterEach (done)->
        userModel.remove phone_number: 'luzhuoquan', done

    describe '<insert>', ()->
        after (done)->
            userModel.remove phone_number: 'test', done

        it 'should new a User instance', (done)->
            user = 
                username: 'test'
                password: 'test'
                phone_number: 'test'
            User.insert user, (err, user)->
                if err then return done(err)
                user.phone_number.should.equal 'test'
                done()

    describe '<remove>', ()->
        it 'should remove some User instances', (done)->
            User.remove phone_number: 'luzhuoquan', (err)->
                if err then return done(err)
                userModel.find phone_number: 'luzhuoquan', (err, user)->
                    if err then return done(err)
                    user.should.have.length 0
                    done()

    describe '<findOne>', ()->
        it 'should find a User instance', (done)->
            User.findOne phone_number: 'luzhuoquan', (err, user)->
                if err then return done(err)
                user.phone_number.should.equal 'luzhuoquan'
                done()

    describe '<find>', ()->
        it 'should find some User instances', (done)->
            User.find phone_number: 'luzhuoquan', (err, user)->
                if err then return done(err)
                user[0].phone_number.should.equal 'luzhuoquan'
                done()

    describe '<update>', ()->
        it 'should update some User instances', (done)->
            User.update {phone_number: 'luzhuoquan'}, $set: {password: 'new_luzhuoquan'}, (err, numAffected, raw)->
                # console.log 'numAffected: '+ numAffected
                # console.log 'raw: ' + raw
                if err then return done(err)
                userModel.findOne phone_number: 'luzhuoquan', (err, user)->
                    if err then return done(err)
                    user.password.should.equal 'new_luzhuoquan'
                    done()

    # describe '<count>', ()->
    #     it 'should count the collection', (done)->
    #         User.count (err, count)->
    #             if err then return done(err)
    #             count.should.equal 1
    #             done()


describe '<find> (or condition)', ()->

    before (done)->
        user = new userModel 
            username: 'luzhuoquan'
            phone_number: 'test'
        user.save done

    before (done)->
        user = new userModel 
            username: 'test'
            phone_number: '123'
        user.save done

    it 'should find the user whose username or phone number match the condition', (done)->
        condition = 
            $or: [{username: 'luzhuoquan'}, {phone_number: '123'}]
            
        User.find condition, (err, users)->
            if err then return done(err)
            (users.some (item)-> item.username is 'luzhuoquan').should.equal true
            (users.some (item)-> item.phone_number is '123').should.equal true
            done()

    after (done)->
        userModel.remove done