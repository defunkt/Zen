module.exports =
  activate: (state) ->
    atom.workspaceView.command "zen:toggle", => @toggle()

  configDefaults:
    hideTreeView: true

  toggle: ->
    workspace = atom.workspaceView
    tabs = atom.packages.getActivePackage('tabs')
    treeView = atom.packages.getActivePackage('tree-view')

    if workspace.is '.zen'
      bgColor = workspace.find('.panes .pane').css('background-color')
      tabs?.activate()
      treeView?.activate()

    else
      bgColor = workspace.find('.editor-colors').css('background-color')
      tabs?.deactivate()

      if atom.config.get('zen.hideTreeView')
        treeView?.deactivate()

    workspace.find('.panes .pane').css('background-color', bgColor)
    workspace.toggleClass 'zen'
