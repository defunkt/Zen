$ = require 'jquery'
# jquery used only to manipulate editor width
# we'd rather move away from this dependency than expand on it

module.exports =
  config:
    fullscreen:
      type: 'boolean'
      default: true
    hideTabs:
      description: 'Disable to keep the current tab visible when Zen.'
      type: 'boolean'
      default: true
    showWordCount:
      description: 'Show the word-count if you have the package installed.'
      type: 'boolean'
      default: false
    width:
      type: 'integer'
      default: atom.config.get 'editor.preferredLineLength'

  activate: (state) ->
    atom.commands.add 'atom-workspace', 'zen:toggle', => @toggle()

  toggle: ->

    body = document.querySelector('body')
    editor = atom.workspace.getActiveTextEditor()

    # should really check current fullsceen state
    fullscreen = atom.config.get 'Zen.fullscreen'
    width = atom.config.get 'Zen.width'

    if editor is undefined # e.g. settings-view
      atom.notifications.addInfo 'Zen cannot be achieved in this view.'
      return

    if atom.config.get 'Zen.hideTabs'
      body.setAttribute 'data-zen-tabs', 'hidden'
    else
      body.setAttribute 'data-zen-tabs', 'visible'

    if atom.config.get 'Zen.showWordCount'
      body.setAttribute 'data-zen-word-count', 'visible'
    else
      body.setAttribute 'data-zen-word-count', 'hidden'

    if body.getAttribute('data-zen') isnt 'true'
      # Enter Mode
      body.setAttribute 'data-zen', 'true'

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
      requestAnimationFrame ->
        $('atom-text-editor:not(.mini)').css 'width', editor.getDefaultCharWidth() * width

      # Listen to font-size changes and update the view width
      @fontChanged = atom.config.onDidChange 'editor.fontSize', ->
        requestAnimationFrame ->
          $('atom-text-editor:not(.mini)').css 'width', editor.getDefaultCharWidth() * width

      # Listen for a pane change to update the view width
      @paneChanged = atom.workspace.onDidChangeActivePaneItem ->
        requestAnimationFrame ->
          $('atom-text-editor:not(.mini)').css 'width', editor.getDefaultCharWidth() * width

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
      body.setAttribute 'data-zen', 'false'

      # Leave fullscreen
      atom.setFullScreen false if fullscreen

      # Disable soft wrap if it was disabled when we zen'd
      if @unSoftWrap
        editor.setSoftWrapped false
        @unSoftWrap = null

      # Reset the config for softwrap if it was enabled when we zen'd
      if @unSetSoftWrap
        atom.config.set('editor.softWrap', false)

      # Unset the width
      $('atom-text-editor:not(.mini)').css 'width', ''

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
