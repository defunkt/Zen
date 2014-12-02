module.exports =
  configDefaults:
    fullscreen: false
    hideTabs: true
    width: atom.config.get 'editor.preferredLineLength'

  unSoftWrap: false
  showTreeView: false
  oldWidth: null
  paneChanged: null

  activate: (state) ->
    atom.workspaceView.command "zen:toggle", => @toggle()

  toggle: ->
    fullscreen = atom.config.get 'Zen.fullscreen'
    hideTabs = atom.config.get 'Zen.hideTabs'
    width = atom.config.get 'Zen.width'

    workspace = atom.workspaceView
    tabs = atom.packages.activePackages.tabs
    editor = workspace.getActiveView().editor
    editorView = workspace.find '.editor:not(.mini)'
    charWidth = editor.getDefaultCharWidth()

    # Enter Zen
    if workspace.is ':not(.zen)'
      # Soft Wrap
      if not editor.isSoftWrapped()
        editor.setSoftWrapped true
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
          view = atom.workspaceView.find '.editor:not(.mini)'
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
