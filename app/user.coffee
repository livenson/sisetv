_ = require 'lodash'
Slide = require './slide'
path = require 'path'
fs = require 'fs'
uploadDir = path.resolve path.join __dirname, '../public/content'
fs.mkdirSync uploadDir if not fs.existsSync uploadDir
defaults = _.partialRight _.assign, (value, other) ->
  if not _.isUndefined(value) then other else undefined
types =
  'img': ['.png', '.jpg', '.gif', '.jpeg', '.bmp']
  'video': ['.mp4', '.webm']
storage = require 'node-persist'
storage.initSync()
class User
  constructor: (data) ->
    if data.slides?
      data.slides = data.slides.map (s) -> new Slide s
    @data = defaults({
      username: null
      password: null
      slides: []
      needsReset: false
      admin: false
      displayName: ""
      registered: false
      registerID: null
      maxSlides: 5
    }, data)

  toJSON: ->
    data = _.cloneDeep(@data)
    if !data.registered
      url = storage.getItemSync('url') + "/register/" + data.registerID
      data.registerLink = url
    data.slides = data.slides.map (s, i) -> _.assign(s.data, id: i)
    return data

  deleteSlide: (id, cb) ->
    if id >= 0 and id < @data.slides.length
      filePath = path.resolve path.join __dirname, "../public/content", @data.slides[id].data.name
      fs.unlinkSync filePath if fs.existsSync filePath
      @data.slides.splice id, 1
      return cb null
    return cb "No slide with ID #{id}"

  addSlide: (data, cb) ->
    name = data.fileName
    i = 1
    ext = name.slice(name.lastIndexOf('.'))
    while fs.existsSync path.join uploadDir, name
      name = data.fileName.slice(0,
          data.fileName.lastIndexOf('.')) + "_" + i + ext
      i++

    data.name = name
    for type, exts of types
      if exts.indexOf(ext.toLowerCase()) != -1
        fs.renameSync data.filePath, path.join uploadDir, name
        data.type = type
        @data.slides.push(new Slide data)
        return cb null
    cb 'Invalid file type ' + ext


module.exports = User