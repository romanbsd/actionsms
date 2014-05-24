require 'net/https'

class Sms
  module Method
    class Bezeq
      URL = URI.parse('https://vast.bezeq.co.il/imsc/interfaces/largeaccount/la3.sms')

      # New instance of Bezeq delivery method
      #
      # @param [Hash] config
      # @option config [String] :account
      # @option config [String] :user
      # @option config [String] :pass
      # @option config [String] :from
      # @option config [String] :port
      def initialize(config)
        @config = config.dup
      end

      # Send an MT message
      # https://vast.bezeq.co.il/imsc/interfaces/largeaccount/la3.sms?account=myaccount&
      #   user=smsuser&pass=mypass&from=1234&to=972541234567&port=0&text=Hello+world
      #
      # @param [Sms::Message] sms
      def deliver!(sms)
        req = Net::HTTP::Post.new(URL.path)
        hash = sms.serializable_hash
        if hash[:to].is_a?(Array)
          to = hash.delete(:to)
          hash['to[]'] = to
        end

        req.form_data = @config.merge(hash)

        res = Net::HTTP.start(URL.host, URL.port) do |http|
          http.request(req)
        end

        case res
        when Net::HTTPSuccess
          true
        else
          raise DeliveryError.new(res.body, res.code)
        end

      end
    end
  end
end
