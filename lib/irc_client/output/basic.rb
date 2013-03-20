require 'colored'

module IRCClient
  module Output
    class Basic
      def transform(network_in, network_out)
        incoming_log = network_in.map { |data|
          data.strip.each_line.map { |line| "< #{line.strip}".black.bold }
        }

        outgoing_log = network_out.map { |data|
          data.strip.each_line.map { |line| "> #{line.strip}".black.bold }
        }

        incoming_log.merge(outgoing_log)
      end
    end
  end
end