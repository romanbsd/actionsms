require 'csv'
class Sms
  module Method
    class File
      def initialize
        @file = ::File.open('/tmp/sms.csv', 'w')
        @file.sync = true
        @file.write("from,to,text\n")
      end

      def deliver!(sms)
        @file.write([sms.from, sms.to, sms.text].to_csv)
      end
    end
  end
end
