# imageDistribution

## 介绍
imageDistribution是使用**Node.js**和**MongoDB**开发的后台系统。主要功能是，将加入同一个圈子
的用户的所上传的图片实时分享到其他用户的客户端。

## 使用的第三方资源

 1. 七牛云存储（http://www.qiniu.com/）
 2. 激光推送（https://www.jpush.cn/）

## 安装部署(development)
```
 install node.js(>=v0.10.0) 和 mongodb
 运行mongodb
 安装grunt
 在项目根目录下，如~/imageDistribution，运行 $ npm install，安装好依赖后，运行$ grunt build
 $ cd .build
 $ npm run-script dev
```

## 接口
占个坑，有空补上。
（在routes文件夹里面也可以通过阅读源码了解接口）

## 需要完善功能
 - 加入多种缓存算法，以提高查询性能
 - 将整个系统抽象，重构为一个图片分享服务。

## License
MIT
