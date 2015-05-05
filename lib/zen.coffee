$ = require 'jquery'
# jquery used only to manipulate editor width
# we'd rather move away from this dependency than expand on it

module.exports =
  config:
    fullscreen:
      type: 'boolean'
      default: true
    tabs:
      description: 'Determines the tab style used while Zen is active.'
      type: 'string'
      default: 'hidden'
      enum: ['hidden', 'single', 'multiple']
    showWordCount:
      description: 'Show the word-count if you have the package installed.'
      type: 'boolean'
      default: false
    softWrap:
      description: 'Enables / Disables soft wrapping when Zen is active.'
      type: 'boolean'
      default: atom.config.get 'editor.softWrap'
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
    softWrap = atom.config.get 'Zen.softWrap'

    if body.getAttribute('data-zen') isnt 'true'

      # Prevent zen mode for undefined editors
      if editor is undefined # e.g. settings-view
        atom.notifications.addInfo 'Zen cannot be achieved in this view.'
        return

      if atom.config.get 'Zen.tabs'
        body.setAttribute 'data-zen-tabs', atom.config.get 'Zen.tabs'

      if atom.config.get 'Zen.showWordCount'
        body.setAttribute 'data-zen-word-count', 'visible'
      else
        body.setAttribute 'data-zen-word-count', 'hidden'

      # Enter Mode
      body.setAttribute 'data-zen', 'true'

      # Soft Wrap
      # Use zen soft wrapping setting's to override the default settings
      if atom.config.get('editor.softWrap') isnt softWrap
        atom.config.set('editor.softWrap', softWrap)
        # restore default when leaving zen mode
        @unSetSoftWrap = true
      if editor.isSoftWrapped() isnt softWrap
        editor.setSoftWrapped softWrap
        # restore default when leaving zen mode
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

      # Hide Minimap
      if $('atom-text-editor /deep/ atom-text-editor-minimap').length
        atom.commands.dispatch(
          atom.views.getView(atom.workspace),
          'minimap:toggle'
        )
        @restoreMinimap = true

      # Enter fullscreen
      atom.setFullScreen true if fullscreen

    else
      # Exit Mode
      body.setAttribute 'data-zen', 'false'

      # Leave fullscreen
      atom.setFullScreen false if fullscreen

      # Restore previous soft wrap setting when leaving zen mode
      if @unSoftWrap
        editor.setSoftWrapped (not softWrap)
        @unSoftWrap = null

      # Reset the config for softwrap when leaving zen mode
      if @unSetSoftWrap
        atom.config.set('editor.softWrap', (not softWrap))

      # Unset the width
      $('atom-text-editor:not(.mini)').css 'width', ''

      # Hack to fix #55 - scrollbars on statusbar after exiting Zen
      $('.status-bar-right').css 'overflow', 'hidden'
      requestAnimationFrame ->
        $('.status-bar-right').css 'overflow', ''

      # Restore TreeView
      if @restoreTree
        atom.commands.dispatch(
          atom.views.getView(atom.workspace),
          'tree-view:show'
        )
        @restoreTree = false

      # Restore Minimap
      if @restoreMinimap and $('atom-text-editor /deep/ atom-text-editor-minimap').length isnt 1
        atom.commands.dispatch(
          atom.views.getView(atom.workspace),
          'minimap:toggle'
        )
        @restoreMinimap = false


      # Stop listening for pane or font change
      @fontChanged?.dispose()
      @paneChanged?.dispose()
