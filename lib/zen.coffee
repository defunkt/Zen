module.exports =
  config:
    fullscreen:
      type: 'boolean'
      default: false
    showTabs:
      description: 'Show the current tab when zen.'
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

    workspace = atom.workspaceView
    editor = workspace.getActiveView().editor
    editorView = workspace.find 'atom-text-editor:not(.mini)'
    body = document.querySelector('body')
    fullscreen = atom.config.get 'Zen.fullscreen'
    width = atom.config.get 'Zen.width'

    if editor is undefined # e.g. settings-view
      atom.notifications.addInfo("Zen cannot be achieved in this view.");
      return

    if atom.config.get 'Zen.showTabs'
      body.setAttribute('zen-tabs', 'true')
    else
      body.setAttribute('zen-tabs', 'false')

    # Enter Zen
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

      # Set width
      @oldWidth = editorView.css 'width'
      editorView.css 'width', editor.getDefaultCharWidth() * width

      # Listen to font-size changes and update the view width
      @fontChanged = atom.config.onDidChange 'editor.fontSize', ->
        editorView.css 'width', editor.getDefaultCharWidth() * width

      # Listen for a pane change to update the view width
      @paneChanged = atom.workspace.onDidChangeActivePaneItem ->
        # wait for the next tick to update the editor view width
        requestAnimationFrame ->
          view = atom.workspaceView.find 'atom-text-editor:not(.mini)'
          view.css 'width': "#{editor.getDefaultCharWidth() * width}px"

      # Enter fullscreen
      atom.setFullScreen true if fullscreen

    else
      # Exit Zen

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

      # Stop listening for pane or font change
      @fontChanged?.dispose()
      @paneChanged?.dispose()

    # One class to rule them all
    workspace.toggleClass 'zen'
