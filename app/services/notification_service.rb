class NotificationService

  def self.call(message, time, color)
    ActionCable.server.broadcast 'notification_channel',
                                 message: message,
                                 time: time,
                                 color: color
  end
end