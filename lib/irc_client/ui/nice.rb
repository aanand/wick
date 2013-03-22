module IRCClient
  module UI
    class Nice
      class State < Struct.new(:joined_channels, :channel_index)
        def channel_name
          channel_index && joined_channels[channel_index]
        end
      end

      def transform(user_in, server_events)
        initial_state = State.new([], nil)

        server_events.log!("server event")

        user_commands = user_in.map { |line| UserCommand.parse(line) }.log!("user_commands")

        manual_changes = user_commands.filter { |cmd| cmd.action == :next or cmd.action == :prev }
                                      .map { |cmd|
                                        proc { |s|
                                          adjust = {next: 1, prev: -1}.fetch(cmd.action)
                                          State.new(s.joined_channels, (s.channel_index+adjust) % s.joined_channels.length)
                                        }
                                      }

        automatic_changes = server_events.filter { |event| event.command == "JOIN" or event.command == "PART" }
                                         .map { |event|
                                          proc { |s|
                                            if event.command == "JOIN"
                                              channel = event.params.first
                                              new_channel_list = s.joined_channels | [channel]
                                              State.new(new_channel_list, new_channel_list.index(channel))
                                            elsif event.command == "PART"
                                              channel = event.params.first

                                              new_channel_list  = s.joined_channels - [channel]
                                              new_channel_index = [s.channel_index, new_channel_list.length-1].min

                                              State.new(new_channel_list, new_channel_index)
                                            end
                                          }
                                         }

        state = manual_changes.merge(automatic_changes)
                              .scan(initial_state) { |s, change| change.call(s) }

        state.log!("state")

        user_commands_with_channel = user_commands.sampling(state) { |cmd, s|
          UserCommand.new(cmd.action, cmd.argument, s.channel_name)
        }.log!("user_commands_with_channel")

        outgoing_messages = user_commands_with_channel.filter { |cmd| cmd.action.nil? }
                                         .map { |cmd| [cmd.channel, "me", cmd.argument] }

        incoming_messages = server_events.filter { |event| event.command == "PRIVMSG" }
                                         .map { |event| [event.params[0], event.user, event.params[1]] }

        message_log = outgoing_messages.merge(incoming_messages).scan(Hash.new([])) { |map, triple|
          channel, user, message = *triple
          map.merge(channel => map[channel] + ["<#{user}> #{message}"])
        }

        message_log.log!("message log")

        user_out = message_log.combine(state) { |current_log, current_state|
          if current_log and current_state
            tabs = current_state.joined_channels.map { |c|
              if c == current_state.channel_name
                c.green
              else
                c
              end
            }

            channel_log = current_log[current_state.channel_name].last(20)

            clear_screen + move_to(1,1) + tabs.join(" ") + "\n" + channel_log.join("\n")
          else
            ""
          end
        }

        # uncomment to disable nice UI and view debug output
        # user_out = Stream.from_array([])

        [user_out, user_commands_with_channel]
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