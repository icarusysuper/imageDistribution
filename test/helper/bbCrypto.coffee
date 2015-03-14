assert = require 'assert'
should = require 'should'
bbCrypto = require '../../helper/bbCrypto'

describe 'crypto unit test', ()->
    describe 'md5', ()->
        it 'should make a md5 crypto', ()->
            bbCrypto.md5('luzhuoquan').should.equal bbCrypto.md5('luzhuoquan')

    describe 'ase192', ()->
        it 'should make a ase 192 crypto', ()->
            enc = bbCrypto.encrypt 'luzhuoquan', 'bb007'
            dec = bbCrypto.decrypt enc, 'bb007'
            dec.should.equal 'luzhuoquan'
