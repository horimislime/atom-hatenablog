HatenablogView = require './hatenablog-view'

module.exports =
  hatenablogView: null

  activate: (state) ->
    @hatenablogView = new HatenablogView(state.atomHatenablogViewState)

  deactivate: ->
    @hatenablogView.destroy()

  serialize: ->
    atomHatenablogViewState: @hatenablogView.serialize()

  configDefaults:
    hatenaId: ""
    blogId: ""
    apiToken: ""
