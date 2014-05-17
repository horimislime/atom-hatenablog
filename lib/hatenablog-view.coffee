{EditorView, View} = require 'atom'
Clipboard = require 'clipboard'

{parseString} = require 'xml2js'

HatenaBlog = require './hatenablog-model'

module.exports =
class HatenablogView extends View

  view = []

  @content: ->
    @div class: "hatena overlay from-top padded", =>
      @div class: "inset-panel", =>
        @div class: "panel-heading", =>
          @span outlet: "title"
          @div class: "btn-toolbar pull-right", outlet: 'toolbar', =>
            @div class: "btn-group", =>
              @button outlet: "privateButton", class: "btn", "Draft"
              @button outlet: "publicButton", class: "btn", "Public"
        @div class: "panel-body padded", =>
          @div outlet: 'signupForm', =>
            @subview 'descriptionEditor', new EditorView(mini:true, placeholderText: 'Title')
            @div class: 'pull-right', =>
              @button outlet: 'publishButton', class: 'btn btn-primary', "Publish"
          @div outlet: 'progressIndicator', =>
            @span class: 'loading loading-spinner-medium'
          @div outlet: 'urlDisplay', =>
            @span ""

  initialize: (serializeState) ->
    view = @
    @handleEvents()
    @hateblo = null
    atom.workspaceView.command "atom-hatenablog:toggle", => @postCurrentFile()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  handleEvents: ->
    @publishButton.on 'click', => @publish()
    @publicButton.on 'click', => @makePublic()
    @privateButton.on 'click', => @makePrivate()
    @descriptionEditor.on 'core:confirm', => @publish()
    @descriptionEditor.on 'core:cancel', => @detach()

  presentSelf: ->
    @makePublic()
    @descriptionEditor.setText @hateblo.description

    @toolbar.show()
    @signupForm.show()
    @urlDisplay.hide()
    @progressIndicator.hide()

    atom.workspaceView.append(this)

    @descriptionEditor.focus()

  postCurrentFile: ->
    @hateblo = new HatenaBlog()

    @hateblo.entryBody = atom.workspace.getActiveEditor().getText()

    @title.text "Publish current file"
    @presentSelf()

  publish: ->
    @showProgressIndicator()
    @hateblo.description = @descriptionEditor.getText()

    @hateblo.post (response) =>
      parseString response, (err, res) ->
        if err
          view.showUrlDisplay("ERROR: #{err}")
          return

        entryUrl = res.entry.link[1].$.href

        Clipboard.writeText entryUrl
        view.showUrlDisplay "Finished! Copied entry url to clipboard."

      setTimeout (=>
        @detach()
      ), 1000

  makePublic: ->
    @publicButton.addClass('selected')
    @privateButton.removeClass('selected')
    @hateblo.isPublic = true

  makePrivate: ->
    @privateButton.addClass('selected')
    @publicButton.removeClass('selected')
    @hateblo.isPublic = false

  showProgressIndicator: ->
    @toolbar.hide()
    @signupForm.hide()
    @urlDisplay.hide()
    @progressIndicator.show()

  showUrlDisplay: (message) ->
    @toolbar.hide()
    @signupForm.hide()
    @urlDisplay.context.innerHTML = "<p>#{message}</p>"
    @urlDisplay.show()
    @progressIndicator.hide()
