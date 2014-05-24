# ActionSMS

ActionSMS was inspired by ActionMailer and it aims to provide a unified interface for using an SMS provider.

## Synopsis

    # config/initializers/sms.rb
    Sms.delivery_method = Sms::Method::Twilio.new(account_sid, auth_token, default_from)
    
	# app/models/user.rb
	require 'actionsms'
	after_create do
	  message = Sms::Message.new(from: '123', to: phone, text: 'Thanks for signing up!')
	  message.deliver
	end

## TODO

* Railtie for doing things like config.action\_sms.delivery_method = :file
* Configurable place for the file