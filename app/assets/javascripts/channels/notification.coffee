App.notification = App.cable.subscriptions.create "NotificationChannel",
  connected: ->

  disconnected: ->

  received: (info) ->
    Materialize.toast(info.info, 5000, 'red')
