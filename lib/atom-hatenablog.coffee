AtomHatenablogView = require './atom-hatenablog-view'

module.exports =
  atomHatenablogView: null

  activate: (state) ->
    @atomHatenablogView = new AtomHatenablogView(state.atomHatenablogViewState)

  deactivate: ->
    @atomHatenablogView.destroy()

  serialize: ->
    atomHatenablogViewState: @atomHatenablogView.serialize()

  configDefaults:
    hatenaId: ""
    blogId: ""
    apiToken: ""
