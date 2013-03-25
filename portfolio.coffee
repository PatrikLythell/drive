google = require './reader'
mimeCheck = require './mimeCheck'
  
portfolio =

  init: (item, @callback) ->
    console.log "constructor"
    google.getChildren null, item.id, (resp) =>
      @findFolders(item) for item in resp.items
      @projects = []
      @i = 0

  findFolders: (item) ->
    console.log "findFolders"
    google.getFile null, item.id, (resp) =>
      if resp.mimeType is 'application/vnd.google-apps.folder'
        @i++
        @addFolder resp, =>
          console.log "and we're back"
          @i--
          @callback(@projects) if @i is 0
        
  addFolder: (item, _callback) ->
    console.log "addFolder"
    project =
      id          : item.id
      title       : item.title
      modified    : item.modifiedDate
      description : item.description
      files       : []
    @projects.push(project)
    @getChildren(@projects.length-1, item.id, _callback) # length for keeping i count on where to put children

  getChildren: (index, id, _callback) ->
    do (index, id) =>
      google.getChildren null, id, (resp) =>
        for item, i in resp.items
          do (item, i) =>
            google.getFile null, item.id, (file) =>
              if mimeCheck.indexOf(file.mimeType) > -1
                thumbIndex = file.thumbnailLink.slice(0, file.thumbnailLink.lastIndexOf('='))
                fileObj =
                  id    : file.id
                  mime  : file.mimeType
                  thumb : thumbIndex
                fileObj.url = file.embedLink if file.mimeType.split('/')[0] is 'video'             
                @projects[index].files.push(fileObj)
                _callback() if i is resp.items.length-1
              else
                _callback() if i is resp.items.length-1
      # If resp.items.length is 0 throw away or display, depends on what makes sense for the user, or alert that it's empty!

sync =
  
  init: (@changes, @portfolio, @callback) ->
    @cb()

  cb: ->
    @callback("init")

module.exports =

  create: (item, callback) ->
    console.log "init"
    portfolio.init item, (resp) ->
      callback(resp)

  sync: (changes, portfolio, callback) ->
    console.log "sync"
    sync.init changes, portfolio, (resp) ->
      callback(resp)
