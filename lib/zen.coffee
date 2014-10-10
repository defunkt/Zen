module.exports =
  configDefaults:
    fullscreen: false
    width: null

  unSoftWrap: false
  showTreeView: false
  oldWidth: null

  activate: (state) ->
    atom.workspaceView.command "zen:toggle", => @toggle()

  toggle: ->
    fullscreen = atom.config.get 'zen.fullscreen'
    width = atom.config.get('zen.width') or atom.config.get('editor.preferredLineLength')
    workspace = atom.workspaceView
    tabs = atom.packages.activePackages.tabs
    editor = workspace.getActiveView().editor
    editorView = workspace.find('.editor:not(.mini)')

    if not editor.isSoftWrapped()
      editor.setSoftWrapped true
      @unSoftWrap = true

    if workspace.find('.tree-view').length
      workspace.trigger 'tree-view:toggle'
      @showTreeView = true

    if workspace.is '.zen'
      bgColor = workspace.find('.panes .pane').css('background-color')
      tabs?.activate()
      atom.setFullScreen false if fullscreen
      if @unSoftWrap
        editor.setSoftWrapped false
        @unSoftWrap = null
      if @showTreeView
        workspace.trigger 'tree-view:toggle'
        @showTreeView = null
      if @oldWidth
        editorView.css 'width', @oldWidth
        @oldWidth = null
    else
      @oldWidth = editorView.css 'width'
      editorView.css 'width', "#{editor.getDefaultCharWidth() * width}px"
      bgColor = workspace.find('.editor-colors').css('background-color')
      tabs?.deactivate()
      atom.setFullScreen true if fullscreen

    workspace.find('.panes .pane').css('background-color', bgColor)
    workspace.toggleClass 'zen'
