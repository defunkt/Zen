module.exports =
  activate: (state) ->
    atom.workspaceView.command "zen:toggle", => @toggle()

  toggle: ->
    workspace = atom.workspaceView
    tabs = atom.packages.activePackages.tabs

    if workspace.is '.zen'
      tabs?.activate()
    else
      tabs?.deactivate()

    workspace.toggleClass 'zen'
