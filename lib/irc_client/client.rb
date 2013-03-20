require 'stream'

module IRCClient
  class Client
    def transform(messages, user_commands)
      connection_start = messages.filter { |msg| msg.command == "CONNECTION_START" }
      nick_and_user_msgs = connection_start.flat_map { |_| Stream.from_array(["NICK frippery", "USER frippery () * FRiPpery"]) }

      ping = messages.filter { |msg| msg.command == "PING" }
      pong = ping.map { |msg| "PONG " + msg.params.join(" ") }

      current_channel = user_commands.filter { |cmd| cmd.action == :join }
                                     .map(&:argument)

      outgoing = user_commands.combine_with_latest(current_channel) { |command, channel| command.to_irc_line(channel) }
                              .compact

      outgoing.merge(nick_and_user_msgs).merge(pong)
    end
  end
end