require 'rubygems'
require 'twilio-ruby'

class Sms
  module Method
    # POST /2010-04-01/Accounts/[AccountSid]/SMS/Messages.json with
    # From, To, Body
    class Twilio
      def initialize(account_sid, auth_token, default_from = nil)
        @account_sid = account_sid
        @auth_token = auth_token
        @from = default_from
      end

      # @param [Sms::Message] sms
      def deliver!(sms)
        from = sms.from || @from
        client.messages.create(from: from, to: sms.to, body: sms.text)
      end

      private
      # Set up a client to talk to the Twilio REST API
      def client
        @client ||= ::Twilio::REST::Client.new(@account_sid, @auth_token)
      end
    end
  end
end
