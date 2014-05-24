require 'sms'

describe Sms do
  let(:hash) do
    {from: '123', to: '234', text: 'test'}
  end

  let(:message) { Sms::Message.new(hash) }

  context 'Delivering SMS' do

    it 'notifies the listeners' do
      listener = double('listener')
      listener.should_receive(:call) do |*params|
        params.first.should eq('deliver.sms')
        params.last.should eq(hash)
      end
      subscriber = ActiveSupport::Notifications.subscribe('deliver.sms', listener)
      Sms.deliver_sms(message) {}
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end

  end

  context 'Receiving SMS' do

    class Receiver < Sms
      def receive(sms)
      end
    end

    it 'receives messages' do
      receiver = double('receiver').tap do |m|
        m.should_receive(:receive) {|msg| msg.serializable_hash.should == hash}
      end
      Receiver.should_receive(:new).and_return(receiver)
      Receiver.receive(hash)
    end

    it 'notifies the listeners' do
      listener = double('listener')
      listener.should_receive(:call) do |*params|
        params.first.should eq('receive.sms')
        params.last.should eq(hash)
      end
      subscriber = ActiveSupport::Notifications.subscribe('receive.sms', listener)
      Receiver.receive(hash)
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end

  end
end
