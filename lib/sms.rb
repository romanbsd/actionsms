class Sms

  # Subclasses need to implement this method in order to handle incoming SMS.
  # It should return the received message.
  #
  # @abstract
  # @param [Sms::Message] sms
  def receive(sms)
    raise NotImplementedError.new('Need to subclass and implement')
  end

  @@delivery_notification_observers = []

  class << self
    def delivery_method=(obj)
      @@delivery_method = obj
    end

    def delivery_method
      @@delivery_method
    end

    # The observer needs to respond to a single method #delivered_sms(sms)
    # which receives the sms that is sent.
    def register_observer(observer)
      unless @@delivery_notification_observers.include?(observer)
        @@delivery_notification_observers << observer
      end
    end

    def unregister_observer(observer)
      @@delivery_notification_observers.delete(observer)
    end

    # Called when delivery is taking place
    #
    # @param [Sms::Message] sms
    def inform_observers(sms)
      @@delivery_notification_observers.each do |observer|
        observer.delivered_sms(sms)
      end
    end

    def deliver_sms(sms) #:nodoc:
      ActiveSupport::Notifications.instrument("deliver.sms") do |payload|
        set_payload_for_sms(payload, sms)
        yield # Let Sms do the delivery actions
      end
    end

    # Receive an SMS
    #
    # @param [Hash] params
    # @option params [String] :from
    # @option params [String] :to
    # @option params [String] :text
    def receive(params)
      ActiveSupport::Notifications.instrument("receive.sms") do |payload|
        sms = Sms::Message.new(params)
        set_payload_for_sms(payload, sms)
        new.receive(sms)
      end
    end

    def set_payload_for_sms(payload, sms) #:nodoc:
      payload[:from] = sms.from
      payload[:to] = sms.to
      payload[:text] = sms.text
    end

  end

  class DeliveryError < StandardError
    attr_reader :code
    def initialize(msg, code = nil)
      @code = code.to_i if code
      super(msg)
    end
  end
end

require 'sms/message'
require 'sms/log_subscriber'
