require 'serialport'
require 'time'

class Sms
  module Method
    class GSM

      def initialize(options = {})
        raise ArgumentError.new('No :smsc was provided') unless options[:smsc]
        @port = SerialPort.new(options[:port] || 3, options[:baud] || 38400, options[:bits] || 8, options[:stop] || 1, SerialPort::NONE)
        @debug = options[:debug]
        cmd("AT")
        # Set to text mode
        cmd("AT+CMGF=1")
        # Set SMSC number
        cmd(%Q{AT+CSCA="#{options[:smsc]}"})
      end

      def close
        @port.close
      end

      private
      def cmd(cmd)
        @port.write(cmd + "\r")
        wait
      end

      def wait
        buffer = ''
        while IO.select([@port], [], [], 0.25)
          chr = @port.getc.chr
          print chr if @debug
          buffer += chr
        end
        buffer
      end

      def deliver!(sms)
        cmd(%Q{AT+CMGS="#{sms.to}"})
        cmd("#{sms.text[0..140]}#{26.chr}\r\r")
        sleep 1
        wait
        cmd("AT")
      end
    end

    Gsm = GSM
  end
end
