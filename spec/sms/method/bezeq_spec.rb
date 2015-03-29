require 'sms'
require 'sms/method/bezeq'
require 'sms/method/file'
require 'webmock/rspec'

describe Sms::Method::Bezeq do
  let(:url) { "http://vast.bezeq.co.il:443/imsc/interfaces/largeaccount/la3.sms" }
  let(:delivery_method) { Sms::Method::Bezeq.new(account: 'a', user: 'u', pass: 'p', from: '222') }

  let(:message) { Sms::Message.new(:to => '123', :text => 'test') }
  let(:body) do
    {"account"=>"a", "user"=>"u", "pass"=>"p", "from"=>"222", "to"=>"123", "text"=>"test" }
  end

  before do
    Sms.delivery_method = delivery_method
  end

  context 'Multiple recipients' do
    let(:message) { Sms::Message.new(:to => %w[num1 num2 num3], :text => 'test') }
    let(:body) do
      {"account"=>"a", "user"=>"u", "pass"=>"p", "from"=>"222", "to"=>%w[num1 num2 num3], "text"=>"test"}
    end

    it 'handles multiple recipients' do
      stub_request(:post, url).
        with(body: body, headers: {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
        to_return(status: 200, body: "OK", headers: {})
      message.deliver
    end

  end

  it "issues POST" do
    stub_request(:post, url).
      with(body: body, headers: {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
      to_return(status: 200, body: "OK", headers: {})
    message.deliver
  end

  it 'handles errors' do
    stub_request(:post, url).with(body: body).
      to_return(status: 400, body: 'Malformed Request', headers: {})

    expect {message.deliver}.to raise_error(Sms::DeliveryError)
    begin
      message.deliver
    rescue Sms::DeliveryError => e
      expect(e.code).to eq(400)
      expect(e.message).to eq('Malformed Request')
    end
  end
end
