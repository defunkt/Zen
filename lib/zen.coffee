module.exports =
  configDefaults:
    fullscreen: false

  unSoftWrap: false

  activate: (state) ->
    atom.workspaceView.command "zen:toggle", => @toggle()

  toggle: ->
    fullscreen = atom.config.get 'zen.fullscreen'
    workspace = atom.workspaceView
    tabs = atom.packages.activePackages.tabs
    editor = workspace.getActiveView().editor

    if not editor.isSoftWrapped()
      editor.setSoftWrapped true
      @unSoftWrap = true

    if workspace.is '.zen'
      bgColor = workspace.find('.panes .pane').css('background-color') # aaaaaaaaaaaaaadsad sadasd asdas dasdasdasdasdsad
      tabs?.activate()
      atom.setFullScreen false if fullscreen
      if @unSoftWrap
        editor.setSoftWrapped false
        @unSoftWrap = null
    else
      bgColor = workspace.find('.editor-colors').css('background-color')
      tabs?.deactivate()
      atom.setFullScreen true if fullscreen

    workspace.find('.panes .pane').css('background-color', bgColor)
    workspace.toggleClass 'zen'
