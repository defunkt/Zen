$ = require 'jquery'
# jquery used only to manipulate editor width
# we'd rather move away from this dependency than expand on it

module.exports =
  config:
    fullscreen:
      type: 'boolean'
      default: true
      order: 1
    softWrap:
      description: 'Enables / Disables soft wrapping when Zen is active.'
      type: 'boolean'
      default: atom.config.get 'editor.softWrap'
      order: 2
    gutter:
      description: 'Shows / Hides the gutter when Zen is active.'
      type: 'boolean'
      default: false
      order: 3
    typewriter:
      description: 'Keeps the cursor vertically centered where possible.'
      type: 'boolean'
      default: false
      order: 4
    minimap:
      description: 'Enables / Disables the minimap plugin when Zen is active.'
      type: 'boolean'
      default: false
      order: 5
    width:
      type: 'integer'
      default: atom.config.get 'editor.preferredLineLength'
      order: 6
    tabs:
      description: 'Determines the tab style used while Zen is active.'
      type: 'string'
      default: 'hidden'
      enum: ['hidden', 'single', 'multiple']
      order: 7
    showWordCount:
      description: 'Show the word-count if you have the package installed.'
      type: 'string'
      default: 'Hidden'
      enum: [
        'Hidden',
        'Left',
        'Right'
      ]
      order: 8

  activate: (state) ->
    atom.commands.add 'atom-workspace', 'zen:toggle', => @toggle()

  toggle: ->

    body = document.querySelector('body')
    editor = atom.workspace.getActiveTextEditor()

    # should really check current fullsceen state
    fullscreen = atom.config.get 'Zen.fullscreen'
    width = atom.config.get 'Zen.width'
    softWrap = atom.config.get 'Zen.softWrap'
    minimap = atom.config.get 'Zen.minimap'

    # Left panel needed for hide/restore
    panels = atom.workspace.getLeftPanels()
    panel = panels[0]

    if body.getAttribute('data-zen') isnt 'true'

      # Prevent zen mode for undefined editors
      if editor is undefined # e.g. settings-view
        atom.notifications.addInfo 'Zen cannot be achieved in this view.'
        return

      if atom.config.get 'Zen.tabs'
        body.setAttribute 'data-zen-tabs', atom.config.get 'Zen.tabs'

      switch atom.config.get 'Zen.showWordCount'
        when 'Left'
          body.setAttribute 'data-zen-word-count', 'visible'
          body.setAttribute 'data-zen-word-count-position', 'left'
        when 'Right'
          body.setAttribute 'data-zen-word-count', 'visible'
          body.setAttribute 'data-zen-word-count-position', 'right'
        when 'Hidden'
          body.setAttribute 'data-zen-word-count', 'hidden'

      body.setAttribute 'data-zen-gutter', atom.config.get 'Zen.gutter'

      # Enter Mode
      body.setAttribute 'data-zen', 'true'

      # Soft Wrap
      # Use zen soft wrapping setting's to override the default settings
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

      if atom.config.get 'Zen.typewriter'
        if not atom.config.get('editor.scrollPastEnd')
          atom.config.set('editor.scrollPastEnd', true)
          @scrollPastEndReset = true
        else
          @scrollPastEndReset = false
        @lineChanged = editor.onDidChangeCursorPosition ->
          halfScreen = Math.floor(editor.getRowsPerPage() / 2)
          cursor = editor.getCursorScreenPosition()
          editor.setScrollTop(editor.getLineHeightInPixels() * (cursor.row - halfScreen))

      @typewriterConfig = atom.config.observe 'Zen.typewriter', =>
        if not atom.config.get 'Zen.typewriter'
          if @scrollPastEndReset
            @scrollPastEndReset = false
            atom.config.set 'editor.scrollPastEnd', false
          @lineChanged?.dispose()
        else
          if not atom.config.get 'editor.scrollPastEnd'
            if not @scrollPastEndReset
              atom.config.set 'editor.scrollPastEnd', true
            @scrollPastEndReset = true
          else
            @scrollPastEndReset = false
          @lineChanged?.dispose()
          @lineChanged = editor.onDidChangeCursorPosition ->
            halfScreen = Math.floor(editor.getRowsPerPage() / 2)
            cursor = editor.getCursorScreenPosition()
            editor.setScrollTop editor.getLineHeightInPixels() * (cursor.row - halfScreen)

      # Hide TreeView
      if $('.nuclide-file-tree').length
        if panel.isVisible()
          atom.commands.dispatch(
            atom.views.getView(atom.workspace),
            'nuclide-file-tree:toggle'
          )
          @restoreTree = true
      else if $('.tree-view').length
        atom.commands.dispatch(
          atom.views.getView(atom.workspace),
          'tree-view:toggle'
        )
        @restoreTree = true

      # Hide Minimap
      if $('atom-text-editor /deep/ atom-text-editor-minimap').length and not minimap
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
      if @unSoftWrap and editor isnt undefined
        editor.setSoftWrapped(atom.config.get('editor.softWrap'));
        @unSoftWrap = null

      # Unset the width
      $('atom-text-editor:not(.mini)').css 'width', ''

      # Hack to fix #55 - scrollbars on statusbar after exiting Zen
      $('.status-bar-right').css 'overflow', 'hidden'
      requestAnimationFrame ->
        $('.status-bar-right').css 'overflow', ''

      # Restore TreeView
      if @restoreTree
        if $('.nuclide-file-tree').length
          unless panel.isVisible()
            atom.commands.dispatch(
              atom.views.getView(atom.workspace),
              'nuclide-file-tree:toggle'
            )
        else
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
      @lineChanged?.dispose()
      if @scrollPastEndReset
        atom.config.set('editor.scrollPastEnd', false)
        @scrollPastEndReset = false
      @typewriterConfig?.dispose()
