require 'colored'
require 'irc/user_command'

module IRC
  module UI
    class Basic
      def initialize(username)
        @username = username
        freeze
      end

      def transform(user_in, server_events)
        user_commands = user_in.skip_start.map { |line| UserCommand.parse(line) }.log!("user_commands")

        outgoing_messages = user_commands.filter { |cmd| cmd.action == :msg }
                                         .map { |cmd| [cmd.channel, @username, cmd.argument] }

        incoming_messages = server_events.filter { |event| event.command == "PRIVMSG" }
                                         .map { |event| [event.params[0], event.user, event.params[1]] }

        message_lines = outgoing_messages.merge(incoming_messages).map { |triple|
          channel, user, message = *triple
          channel.green + " " + "<#{user}>".yellow + " #{message}"
        }

        event_lines = server_events.filter { |event| event.command != "PRIVMSG" }
                                   .map { |event| event.line.blue }

        user_out = message_lines.merge(event_lines)

        [user_out, user_commands]
      end
    end
  end
end

