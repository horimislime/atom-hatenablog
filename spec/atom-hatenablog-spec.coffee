{WorkspaceView} = require 'atom'
AtomHatenablog = require '../lib/atom-hatenablog'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "AtomHatenablog", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('atom-hatenablog')

  describe "when the atom-hatenablog:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.atom-hatenablog')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'atom-hatenablog:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.atom-hatenablog')).toExist()
        atom.workspaceView.trigger 'atom-hatenablog:toggle'
        expect(atom.workspaceView.find('.atom-hatenablog')).not.toExist()
