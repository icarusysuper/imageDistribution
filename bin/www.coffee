#!/usr/bin/env node
require('coffee-script/register');
debug = require('debug')('BB007');
app = require('../app');
env = process.env.NODE_ENV || 'development'
config = require '../config'
app.set('port', process.env.PORT || config[env].port);

server = app.listen app.get('port'), ()-> 
  debug('Express server listening on port ' + server.address().port);
  console.log ('BB007 server listening on port ' + server.address().port);

