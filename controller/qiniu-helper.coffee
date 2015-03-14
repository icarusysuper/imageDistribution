config   = require '../config'
qiniu    = require 'qiniu'

qiniu.conf.ACCESS_KEY = config.qiniu.access_key
qiniu.conf.SECRET_KEY = config.qiniu.secret_key

exports.getUptoken = (bucketname)->
    bucketname = bucketname || config.qiniu.bucketname
    putPolicy = new qiniu.rs.PutPolicy bucketname

    # putPolicy.returnUrl = config.qiniu.returnUrl
    # putPolicy.returnBody = config.qiniu.returnBody

    putPolicy.token()


exports.generateDownloadUrls = (reqPhotoParams)->
    reqPhotoParams = reqPhotoParams || []
    downloadUrls = []
    for item in reqPhotoParams
        url = qiniu.rs.makeBaseUrl config.qiniu.domain, item.etag

        if item.width or item.height
            iv = new qiniu.fop.ImageView(item.mode, item.width, item.height, item.quality, item.format)
            url = iv.makeRequest url

        policy = new qiniu.rs.GetPolicy()
        downloadUrls.push
            etag: item.etag
            url: policy.makeRequest(url)
    downloadUrls

