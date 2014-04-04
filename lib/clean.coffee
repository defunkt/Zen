module.exports =
  activate: (state) ->
    atom.workspaceView.command "clean:toggle", => @toggle()

  toggle: ->
    workspace = atom.workspaceView

    workspace.toggleClass 'clean'
