require 'sms'

describe Sms do
  let(:hash) do
    {from: '123', to: '234', text: 'test'}
  end

  let(:message) { Sms::Message.new(hash) }

  context 'Delivering SMS' do

    it 'notifies the listeners' do
      listener = double('listener')
      expect(listener).to receive(:call) do |*params|
        expect(params.first).to eq('deliver.sms')
        expect(params.last).to eq(hash)
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
        expect(m).to receive(:receive) {|msg| expect(msg.serializable_hash).to eq(hash)}
      end
      expect(Receiver).to receive(:new).and_return(receiver)
      Receiver.receive(hash)
    end

    it 'notifies the listeners' do
      listener = double('listener')
      expect(listener).to receive(:call) do |*params|
        expect(params.first).to eq('receive.sms')
        expect(params.last).to eq(hash)
      end
      subscriber = ActiveSupport::Notifications.subscribe('receive.sms', listener)
      Receiver.receive(hash)
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end

  end
end
