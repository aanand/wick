module IRCClient
  module UI
    class Nice
      State = Struct.new(:joined_channels, :current_channel, :channel_messages)

      def transform(user_in, server_events)
        initial_state = State.new([], nil, {})

        server_events.log!("server event")

        state = server_events.scan(initial_state) { |last_state, event|
          if event.command == "JOIN"
            channel = event.params.first

            State.new(
              last_state.joined_channels | [channel],
              channel,
              last_state.channel_messages.merge(channel => [])
            )
          elsif event.command == "PART"
            channel = event.params.first

            new_channel_list    = last_state.joined_channels - [channel]
            new_current_channel = new_channel_list.first

            State.new(
              new_channel_list,
              new_current_channel,
              last_state.channel_messages
            )
          elsif event.command == "PRIVMSG"
            channel = event.params.first
            new_channel_messages_map = last_state.channel_messages.dup

            if new_channel_messages_map.has_key?(channel)
              new_channel_messages_map[channel] << event.params[1]
            end

            State.new(
              last_state.joined_channels,
              last_state.current_channel,
              new_channel_messages_map
            )
          else
            last_state
          end
        }

        state.log!("state")

        user_commands = user_in.sampling(state) { |line, s| UserCommand.parse(line, s.current_channel) }.log!("user command")

        user_out = Stream.from_array([])

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