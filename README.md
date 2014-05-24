# ActionSMS

ActionSMS was inspired by ActionMailer and it aims to provide a unified interface for using an SMS provider.

## Synopsis

```ruby
# config/initializers/sms.rb
Sms.delivery_method = Sms::Method::Twilio.new(account_sid, auth_token, default_from)

```

```ruby
# app/models/user.rb
require 'actionsms'
after_create do
  message = Sms::Message.new(from: '123', to: phone, text: 'Thanks for signing up!')
  message.deliver
end
```

Example controller receiving SMS:
```ruby
require 'sms'

class SmsController < ActionController::Metal
  def receive
    self.content_type = 'text/plain'
    unless %w[from to text].all? { |key| params.key?(key) }
      self.status = 400
      self.response_body = "Invalid Request\n"
      return
    end
    SmsReceiver.receive(params)
    self.response_body = ''
  end
end

class SmsReceiver < Sms
  def receive(sms)
    Rails.logger.info "SMS: #{sms.inspect}"
  end
end
```

## TODO

* Railtie for doing things like config.action\_sms.delivery_method = :file
* Configurable place for the file
