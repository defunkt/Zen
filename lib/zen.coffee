$ = require 'jquery'

module.exports =
  config:
    fullscreen:
      type: 'boolean'
      default: true
    showTabs:
      description: 'Show the current tab in distraction free mode.'
      type: 'boolean'
      default: false
    width:
      type: 'integer'
      default: atom.config.get 'editor.preferredLineLength'

  activate: (state) ->
    atom.commands.add 'atom-workspace', 'distraction-free:toggle', => @toggle()

  toggle: ->

    body = document.querySelector('body')
    editor = atom.workspace.getActiveTextEditor()

    # should really check current fullsceen state
    fullscreen = atom.config.get 'distraction-free-mode.fullscreen'
    width = atom.config.get 'distraction-free-mode.width'

    if editor is undefined # e.g. settings-view
      atom.notifications.addInfo("Distraction free mode cannot be toggled in this view.");
      return

    if atom.config.get 'distraction-free-mode.showTabs'
      body.setAttribute('zen-tabs', 'true')
    else
      body.setAttribute('zen-tabs', 'false')

    if body.getAttribute('zen') isnt 'true'
      # Enter Mode
      body.setAttribute('zen', 'true')

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

      # Set width
      @oldWidth = $('atom-text-editor').css 'width'
      $('atom-text-editor').css 'width', editor.getDefaultCharWidth() * width

      # Listen to font-size changes and update the view width
      @fontChanged = atom.config.onDidChange 'editor.fontSize', ->
        $('atom-text-editor').css 'width', editor.getDefaultCharWidth() * width

      # Listen for a pane change to update the view width
      @paneChanged = atom.workspace.onDidChangeActivePaneItem ->
        # wait for the next tick to update the editor view width
        requestAnimationFrame ->
          $('atom-text-editor').css 'width', editor.getDefaultCharWidth() * width

      # Hide TreeView
      if $('.tree-view').length
        atom.commands.dispatch(
          atom.views.getView(atom.workspace),
          'tree-view:toggle'
        )
        @restoreTree = true

      # Enter fullscreen
      atom.setFullScreen true if fullscreen

    else
      # Exit Mode
      body.setAttribute 'zen', 'false'

      # Leave fullscreen
      atom.setFullScreen false if fullscreen

      # Disable soft wrap if it was disabled when we zen'd
      if @unSoftWrap
        editor.setSoftWrapped false
        @unSoftWrap = null

      # Reset the config for softwrap if it was enabled when we zen'd
      if @unSetSoftWrap
        atom.config.set('editor.softWrap', false)

      # Reset the width
      if @oldWidth
        $('atom-text-editor').css 'width', @oldWidth
        @oldWidth = null

      # Hide TreeView
      if @restoreTree
        atom.commands.dispatch(
          atom.views.getView(atom.workspace),
          'tree-view:show'
        )
        @restoreTree = false


      # Stop listening for pane or font change
      @fontChanged?.dispose()
      @paneChanged?.dispose()
