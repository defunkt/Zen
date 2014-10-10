module.exports =
  configDefaults:
    fullscreen: false

  activate: (state) ->
    atom.workspaceView.command "zen:toggle", => @toggle()

  toggle: ->
    fullscreen = atom.config.get 'zen.fullscreen'
    workspace = atom.workspaceView
    tabs = atom.packages.activePackages.tabs

    if workspace.is '.zen'
      bgColor = workspace.find('.panes .pane').css('background-color')
      tabs?.activate()
      atom.setFullScreen false if fullscreen
    else
      bgColor = workspace.find('.editor-colors').css('background-color')
      tabs?.deactivate()
      atom.setFullScreen true if fullscreen

    workspace.find('.panes .pane').css('background-color', bgColor)
    workspace.toggleClass 'zen'
