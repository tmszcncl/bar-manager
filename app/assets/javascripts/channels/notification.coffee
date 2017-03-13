App.notification = App.cable.subscriptions.create "NotificationChannel",
  connected: ->

  disconnected: ->

  received: (data) ->
    Materialize.toast(data.message, data.time, "#{data.color}")
