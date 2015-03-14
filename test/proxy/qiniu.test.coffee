assert = require 'assert'
should = require 'should'

app = require '../../app'
request = require('supertest')(app)

config = require '../../config'
qiniu = require 'qiniu'

describe 'qiniu test: ', ()->
    it 'should upload an image to qiniu bucket', (done)->
        request.get('/uptoken').expect 200, (err, res)->
            done()
