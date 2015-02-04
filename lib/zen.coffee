module.exports =
  config:
    fullscreen:
      type: 'boolean'
      default: false
    hideTabs:
      type: 'boolean'
      default: false
    width:
      type: 'integer'
      default: atom.config.get 'editor.preferredLineLength'

  unSoftWrap: false
  showTreeView: false
  oldWidth: null
  paneChanged: null

  activate: (state) ->
    atom.commands.add 'atom-workspace', 'zen:toggle', => @toggle()

  toggle: ->
    # Enter Zen
    workspace = atom.workspaceView
    tabs = atom.packages.activePackages.tabs
    editor = workspace.getActiveView().editor
    editorView = workspace.find 'atom-text-editor:not(.mini)'

    if editor is undefined # e.g. settings-view
      atom.notifications.addInfo("Zen cannot be achieved in this view.");
      return

    fullscreen = atom.config.get 'Zen.fullscreen'
    hideTabs = atom.config.get 'Zen.hideTabs'
    width = atom.config.get 'Zen.width'
    charWidth = editor.getDefaultCharWidth()

    if workspace.is ':not(.zen)'
      # Soft Wrap
      # set it so it's true for all new editors you open in zen
      if atom.config.get('editor.softWrap') is false
        atom.config.set('editor.softWrap', true)
        # remember to put it back later
        @unSetSoftWrap = true
      if editor.isSoftWrapped() is false
        editor.setSoftWrapped true
        # and remember to set is back later
        @unSoftWrap = true

      # Hide TreeView
      if workspace.find('.tree-view').length
        workspace.trigger 'tree-view:toggle'
        @showTreeView = true

      # Hide tabs
      tabs?.deactivate() if hideTabs

      # Set width
      @oldWidth = editorView.css 'width'
      editorView.css 'width', "#{charWidth * width}px"

      # Get current background color
      bgColor = workspace.find('.editor-colors').css 'background-color'

      # Enter fullscreen
      atom.setFullScreen true if fullscreen

      # Listen for a pane change to update the view width
      @paneChanged = atom.workspace.onDidChangeActivePaneItem ->
        # wait for the next tick to update the editor view width
        requestAnimationFrame ->
          view = atom.workspaceView.find 'atom-text-editor:not(.mini)'
          view.css 'width': "#{charWidth * width}px"
    else
      # Exit Zen

      # Get current background color
      bgColor = workspace.find('.panes .pane').css 'background-color'

      # Show tabs
      tabs?.activate() if hideTabs

      # Leave fullscreen
      atom.setFullScreen false if fullscreen

      # Disable soft wrap if it was disabled when we zen'd
      if @unSoftWrap
        editor.setSoftWrapped false
        @unSoftWrap = null

      # Reset the config for softwrap if it was enabled when we zen'd
      if @unSetSoftWrap
        atom.config.set('editor.softWrap', false)

      # Show TreeView if it was shown when we zen'd
      if @showTreeView
        workspace.trigger 'tree-view:toggle'
        @showTreeView = null

      # Reset the width
      if @oldWidth
        editorView.css 'width', @oldWidth
        @oldWidth = null

      # Stop listening for pane change
      @paneChanged?.dispose()

    # Reset background color
    workspace.find('.panes .pane').css 'background-color', bgColor

    # One class to rule them all
    workspace.toggleClass 'zen'
