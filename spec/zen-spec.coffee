Zen = require '../lib/zen'
{WorkspaceView} = require 'atom'

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
      expect(atom.workspaceView).not.toHaveClass('zen')

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'zen:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView).toHaveClass('zen')
        atom.workspaceView.trigger 'zen:toggle'
        expect(atom.workspaceView).not.toHaveClass('zen')
