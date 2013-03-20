google = require './reader'
mimeCheck = require './mimeCheck'
  
class portfolio

  constructor: (item, @callback) ->
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
          @callback() if @i is 0
        
  addFolder: (item, callback) ->
    console.log "addFolder"
    project =
      id          : item.id
      title       : item.title
      modified    : item.modifiedDate
      description : item.description
      files       : []
    @projects.push(project)
    @getChildren(@projects.length-1, item.id, callback) # length for keeping i count on where to put children

  getChildren: (index, id, callback) ->
    do (index, id) =>
      google.getChildren null, id, (resp) =>
        for item, i in resp.items
          do (item, i) =>
            google.getFile null, item.id, (file) =>
              if mimeCheck.indexOf(file.mimeType) > -1
                thumbIndex = file.thumbnailLink.slice(0, file.thumbnailLink.lastIndexOf('='))
                fileObj =
                  id: file.id
                  mime: file.mimeType
                  thumb: thumbIndex
                fileObj.url = file.embedLink if file.mimeType.split('/')[0] is 'video'             
                @projects[i].files.push(fileObj)
                callback() if i is resp.items.length-1
              else
                callback() if i is resp.items.length-1
      # If resp.items.length is 0 throw away or display, depends on what makes sense for the user, or alert that it's empty!

  showObject: ->
    return @projects

class sync
  
  constructor: (@changes, @portfolio) ->
    console.log "init"

module.exports =
  
  create: (item, callback) ->
    console.log "init"
    portfolio item, ->
      callback(portfolio.showObject())
