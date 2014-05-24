class Sms
  module Method
    class Kannel
      def deliver!(sms)
        args = {}
        args[:from] = sms.from if sms.from
        sms = ::Kannel::Sms.new(sms.to, sms.text, args)
        sms.send!
      end
    end
  end
end
