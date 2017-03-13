class NotificationService

  def self.call(message)
    ActionCable.server.broadcast 'notification_channel',
                                 message: message
  end
end