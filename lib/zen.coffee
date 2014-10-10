module.exports =
  activate: (state) ->
    atom.workspaceView.command "zen:toggle", => @toggle()

  toggle: ->
    workspace = atom.workspaceView
    tabs = atom.packages.activePackages.tabs

    if workspace.is '.zen'
      bgColor = workspace.find('.panes .pane').css('background-color')
      tabs?.activate()
      atom.setFullScreen(false)
    else
      bgColor = workspace.find('.editor-colors').css('background-color')
      tabs?.deactivate()
      atom.setFullScreen(true)

    workspace.find('.panes .pane').css('background-color', bgColor)
    workspace.toggleClass 'zen'
