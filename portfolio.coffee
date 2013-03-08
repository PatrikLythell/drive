google = require './reader'
mimeCheck = require './mimeCheck'
  
class Portfolio

  _projects: []
  _iter: 0
  _cb: null

  constructor: (@item, @callback) ->
    console.log "constructor"
    @_cb = @callback
    google.getChildren null, @item.id, (resp) =>
      @findFolders(item) for item in resp.items

  findFolders: (item) ->
    console.log "findFolders"
    google.getFile null, item.id, (resp) =>
      @addFolder(resp) if resp.mimeType is 'application/vnd.google-apps.folder'

  addFolder: (item) ->
    console.log "addFolder"
    project =
      index       : item.id
      title       : item.title
      modified    : item.modifiedDate
      description : item.description
      files       : []
    @_projects.push(project)
    @getChildren(@_projects.length-1, item.id) # length for keeping i count on where to put children

  getChildren: (i, id) ->
    console.log "getChildren"
    do (i, id) =>
      google.getChildren null, id, (resp) =>
        for item, j in resp.items
          do (item, j) =>
            google.getFile null, item.id, (file) =>
              @_projects[i].files.push(file.title) if mimeCheck.indexOf(file.mimeType) > -1
              if j is resp.items.length-1
                console.log "callback"
                @_cb()
      # If resp.items.length is 0 throw away or display, depends on what makes sense for the user, or alert that it's empty!

  getObj: ->
    return @_projects

module.exports =
  
  create: (item, callback) ->
    console.log "init"
    portfolio = new Portfolio item, (obj) ->
      setTimeout ->
        callback(portfolio.getObj())
      , 500
