crypto = require 'crypto'
config = require '../config'

encrypt = (str, secret)->
    cipher = crypto.createCipher 'aes192', secret
    enc = cipher.update str, 'utf8', 'hex'
    enc += cipher.final 'hex'

decrypt = (str, secret)->
    decipher = crypto.createDecipher 'aes192', secret
    dec = decipher.update str, 'hex', 'utf8'
    dec += decipher.final 'utf8'

md5 = (str)->
    md5sum = crypto.createHash 'md5'
    md5sum.update str
    str = md5sum.digest 'hex'

encodePassword = (pass)->
    encrypt pass, config.pass_crypto_secret


exports.encrypt = encrypt
exports.decrypt = decrypt
exports.md5 = md5

exports.encodePassword = encodePassword