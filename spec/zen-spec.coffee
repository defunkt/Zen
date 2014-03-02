Zen = require '../lib/zen'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "Zen", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('zen')

  describe "when the zen:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.zen')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'zen:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.zen')).toExist()
        atom.workspaceView.trigger 'zen:toggle'
        expect(atom.workspaceView.find('.zen')).not.toExist()

  describe "when the `zen.hideTreeView` config is false", ->
    it "allows the tree view to remain active when entering zen mode", ->
      atom.config.set('zen.hideTreeView', false)
      atom.packages.activatePackage('tree-view')

      runs ->
        atom.workspaceView.trigger 'tree-view:toggle'
        expect(atom.workspaceView.find(".tree-view")).toExist()

  describe "when the `zen.hideTreeView` config is true", ->
    it "deactivates the tree view when entering zen mode", ->
      atom.config.set('zen.hideTreeView', true)
      atom.packages.activatePackage('tree-view')

      runs ->
        atom.workspaceView.trigger 'tree-view:toggle'
        expect(atom.workspaceView.find(".tree-view")).not.toExist()
