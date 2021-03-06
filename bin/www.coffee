#!/usr/bin/env node

###
  Module dependencies.
###
require('source-map-support').install()
app = require '../app/app'
debug = require('debug')('sisetv:server')
http = require 'http'
chalk = require 'chalk'
getIP = require('external-ip')()

###
    Normalize a port into a number, string, or false.
###

normalizePort = (val) ->
  port = parseInt val, 10
  return val if isNaN port
  return port if port >= 0
  false

###
  Get port from environment and store in Express.
###
port = normalizePort (process.argv.length > 2 and process.argv[2]) or process.env.PORT or '3000'
app.set 'port', port

###
  Create HTTP server.
###

server = http.createServer app

###
  Event listener for HTTP server "error" event.
###

onError = (error) ->
  if error.syscall != 'listen'
    throw error;
  switch error.code
    when 'EACCES'
      console.error chalk.red "#{bind} requires elevated privileges"
      process.exit 1
    when 'EADDRINUSE'
      console.error chalk.red "#{bind} is already in use"
      process.exit 1
    else
      throw error

###
  Event listener for HTTP server "listening" event.
###

onListening = () ->
  addr = server.address();
  bind = if typeof addr == 'string' then "pipe #{addr}" else "port #{addr.port}";
  debug('Listening on ' + bind);

###
  Listen on provided port, on all network interfaces.
###

server.listen port
server.on 'error', onError
server.on 'listening', onListening
storage = require 'node-persist'
storage.initSync()
bind = if typeof port == 'string' then "Pipe #{port}" else "Port #{port}"

getIP (err, ip) ->
  if err
    console.log chalk.red 'Failed to get external IP, but SiseTV is still running'
    ip = 'localhost'
  else
    console.log chalk.cyan 'SiseTV is now running'
  app.set 'ip', ip
  url = 'http://' + ip + ':' + (app.get 'port')
  storage.setItemSync 'url', url
  console.log chalk.cyan "Visit #{chalk.magenta url + '/admin'} for the administration interface"
  console.log chalk.cyan "Point the browsers on your information display computers to #{chalk.magenta url}"



