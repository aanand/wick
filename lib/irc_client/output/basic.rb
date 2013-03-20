require 'colored'

module IRCClient
  module Output
    class Basic
      def transform(messages, user_commands, debug)
        debug.map { |line| line.black.bold }
      end
    end
  end
end