module.exports =
  activate: (state) ->
    atom.workspaceView.command "zen:toggle", => @toggle()

  toggle: ->
    workspace = atom.workspaceView
    tabs = atom.packages.activePackages.tabs

    editorBgColor = workspace.find('.editor-colors').css('background-color')
    paneBgColor = workspace.find('.panes .pane').css('background-color')

    if workspace.is '.zen'
      workspace.find('.panes .pane').css('background-color', paneBgColor)
      tabs?.activate()
    else
      workspace.find('.panes .pane').css('background-color', editorBgColor)
      tabs?.deactivate()

    workspace.toggleClass 'zen'
