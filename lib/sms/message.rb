class Sms
  class Message

    # Default: true
    attr_accessor :perform_deliveries

    # Default: true
    attr_accessor :raise_delivery_errors

    # Default: Sms
    # Should respond_to :deliver_sms
    attr_accessor :delivery_handler

    attr_reader :from, :to, :text
    def initialize(args = {})
      @delivery_handler = Sms
      @perform_deliveries = true
      @raise_delivery_errors = true
      @from, @to, @text = args[:from], args[:to], args[:text]
    end

    # Hash representing the message
    #
    # @return [Hash] message
    def serializable_hash
      {to: to, text: text}.tap {|hash| hash[:from] = from if from}
    end

    # Perform the delivery of this message
    #
    # @return [Sms::Message] self
    def deliver
      #inform_interceptors
      if delivery_handler
        delivery_handler.deliver_sms(self) { do_delivery }
      else
        do_delivery
      end
      inform_observers
      self
    end

    private
    def do_delivery
      begin
        if perform_deliveries
          delivery_method.deliver!(self)
        end
      rescue Exception => e
        raise e if raise_delivery_errors
      end
    end

    def delivery_method
      Sms.delivery_method
    end

    def inform_observers
      Sms.inform_observers(self)
    end

  end
end
