module IRC
  module UI
    class Nice
      class ChannelState < Struct.new(:joined_channels, :current_index)
        def current_channel_name
          current_index && joined_channels[current_index]
        end
      end

      def initialize(username)
        @username = username
        freeze
      end

      def transform(user_in, server_events)
        user_commands_without_channel = user_in.skip_start.map { |line| UserCommand.parse(line) }.log!("user_commands_without_channel")

        channel_state = get_channel_state(user_commands_without_channel, server_events).log!("channel_state")

        user_commands = user_commands_without_channel.sampling(channel_state) { |cmd, cs|
          cmd.with_channel(cs.current_channel_name)
        }.log!("user_commands")

        message_log = get_message_log(user_commands, server_events).log!("message log")

        user_out = render_output(channel_state, message_log) # Stream.from_array([])

        [user_out, user_commands]
      end

      def get_channel_state(user_commands_without_channel, server_events)
        manual_changes    = get_manual_state_changes(user_commands_without_channel)
        automatic_changes = get_automatic_state_changes(server_events)

        initial_state = ChannelState.new([], nil)

        manual_changes.merge(automatic_changes)
                      .scan(initial_state) { |cs, change| change.call(cs) }
      end

      def get_manual_state_changes(user_commands_without_channel)
        user_commands_without_channel.filter { |cmd| cmd.action == :next or cmd.action == :prev }
                     .map { |cmd|
                       proc { |cs|
                         if cmd.action == :next
                           ChannelState.new(cs.joined_channels, (cs.current_index+1) % cs.joined_channels.length)
                         elsif cmd.action == :prev
                           ChannelState.new(cs.joined_channels, (cs.current_index-1) % cs.joined_channels.length)
                         end
                       }
                     }
      end

      def get_automatic_state_changes(server_events)
        server_events.filter { |event| event.user == @username }
                     .filter { |event| event.command == "JOIN" or event.command == "PART" }
                     .map { |event|
                       proc { |cs|
                         if event.command == "JOIN"
                           channel = event.params.first
                           new_channel_list = cs.joined_channels | [channel]
                           ChannelState.new(new_channel_list, new_channel_list.index(channel))
                         elsif event.command == "PART"
                           channel = event.params.first

                           new_channel_list  = cs.joined_channels - [channel]
                           new_channel_index = [cs.current_index, new_channel_list.length-1].min

                           ChannelState.new(new_channel_list, new_channel_index)
                         end
                       }
                     }
      end

      def get_message_log(user_commands, server_events)
        outgoing_messages = user_commands.filter { |cmd| cmd.action.nil? }
                                         .map { |cmd| [cmd.channel, @username, cmd.argument] }

        incoming_messages = server_events.filter { |event| event.command == "PRIVMSG" }
                                         .map { |event| [event.params[0], event.user, event.params[1]] }

        outgoing_messages.merge(incoming_messages).scan(Hash.new([])) { |map, triple|
          channel, user, message = *triple
          map.merge(channel => map[channel] + ["<#{user}> #{message}"])
        }
      end

      def render_output(channel_state, message_log)
        message_log.combine(channel_state) { |current_log, cs|
          if current_log and cs
            tabs = cs.joined_channels.map { |c|
              if c == cs.current_channel_name
                c.green
              else
                c
              end
            }

            channel_log = current_log[cs.current_channel_name].last(20)

            clear_screen + move_to(1,1) + tabs.join(" ") + "\n" + channel_log.join("\n")
          else
            ""
          end
        }
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
