require 'colored'

require 'irc_client/user_command'

module IRCClient
  module UI
    class Raw
      def transform(user_in, server_events)
        user_commands = user_in.map { |line| UserCommand.parse("/raw #{line}", nil) }
        [server_events.map(&:to_s), user_commands]
      end
    end
  end
end