path = require 'path'

module.exports = 
    development:
        hostname: 'localhost'
        port: 3000

        db_host: 'localhost'
        db_port: 27017
        db_name: '<your database name>'
        uri: '<your database uri>'

    relation: [
        'father'
        'mother'
        'grandfather'
        'grandmother'
        'maternal_grandfather'
        'maternal_grandmother'
        'other'
    ]

    cookie_name: '<cookie name your want>'
    cookie_secret: '<cookie secret your want>'

    pass_crypto_secret: '<password crypto secret>'

    default_avatar: path.join __dirname, 'public', 'static_images', 'default.jpg'

    upload_dir: path.join __dirname, 'public', 'user_data', 'images'

    qiniu: 
        domain: '<your qiniu domain>'
        access_key: '<your qiniu access key>'
        secret_key: '<your qiniu secret key>'

        bucketname: '<your qiniu bucket name>'

    jpush:
        app_key: '<your JPush app key>'
        master_secret: '<your JPush secret key>'

    notification:
        title: '<the default notification title>'
