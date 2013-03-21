module IRCClient
  module UI
    class Nice
      State = Struct.new(:joined_channels, :current_channel)

      def transform(user_in, server_events)
        initial_state = State.new([], nil)

        server_events.log!("server event")

        state = server_events.scan(initial_state) { |last_state, event|
          if event.command == "JOIN"
            channel = event.params.first

            State.new(last_state.joined_channels | [channel], channel)
          elsif event.command == "PART"
            channel = event.params.first

            new_channel_list    = last_state.joined_channels - [channel]
            new_current_channel = new_channel_list.first

            State.new(new_channel_list, new_current_channel)
          else
            last_state
          end
        }

        state.log!("state")

        user_commands = user_in.sampling(state) { |line, s| UserCommand.parse(line, s.current_channel) }.log!("user command")

        outgoing_messages = user_commands.filter { |cmd| cmd.action.nil? }
                                         .map { |cmd| [cmd.channel, "me", cmd.argument] }

        incoming_messages = server_events.filter { |event| event.command == "PRIVMSG" }
                                         .map { |event| [event.params[0], event.user, event.params[1]] }

        message_log = outgoing_messages.merge(incoming_messages).scan(Hash.new([])) { |map, triple|
          channel, user, message = *triple
          map.merge(channel => map[channel] + ["<#{user}> #{message}"])
        }

        message_log.log!("message log")

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