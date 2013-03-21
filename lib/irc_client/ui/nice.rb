require 'record'

module IRCClient
  module UI
    class Nice
      State = Record[:joined_channels, :current_channel]

      def transform(user_in, server_events)
        initial_state = State.new([], nil)

        state = server_events.scan(initial_state) { |last_state, event|
          channel = event.params.first

          if event.command == "JOIN"
            last_state.joined_channels(last_state.joined_channels | [channel])
                      .current_channel(channel)
          elsif event.command == "PART"
            new_channel_list    = last_state.joined_channels - [channel]
            new_current_channel = new_channel_list.first

            last_state.joined_channels(new_channel_list)
                      .current_channel(new_current_channel)
          else
            last_state
          end
        }

        state.log!("state")

        user_commands = user_in.sampling(state) { |line, s| UserCommand.parse(line, s.current_channel) }.log!("user command")

        user_out = server_events.map(&:to_s)

        [user_out, user_commands]
      end

      def clear_screen
        ansi("2J")
      end

      def move_to(x, y)
        ansi("#{x};#{y}H")
      end

      def ansi(str)
        "\e[#{str}"
      end
    end
  end
end