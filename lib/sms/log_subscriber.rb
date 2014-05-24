require 'securerandom'
require 'active_support/log_subscriber'
require 'active_support/notifications'

class Sms
  class LogSubscriber < ActiveSupport::LogSubscriber
    def deliver(event)
      recipient = event.payload[:to]
      info("Sent sms to #{recipient} (%1.fms)" % event.duration)
      debug(event.payload[:text])
    end

    def receive(event)
      sender = event.payload[:from]
      info("Received sms from #{sender} (%1.fms)" % event.duration)
      debug(event.payload[:text])
    end
  end
end

Sms::LogSubscriber.attach_to :sms
