require 'stream'

require 'irc_client/message'
require 'irc_client/user_command'

module IRCClient
  class Client
    def transform(network_in, user_in)
      messages = network_in.map { |line| Message.parse(line) }

      connection_start = messages.filter { |msg| msg.command == "CONNECTION_START" }
      nick_and_user_msgs = connection_start.flat_map { |_| Stream.from_array(["NICK frippery", "USER frippery () * FRiPpery"]) }

      ping = messages.filter { |msg| msg.command == "PING" }
      pong = ping.map { |msg| "PONG " + msg.params.join(" ") }

      user_commands = user_in.map { |line| UserCommand.parse(line) }

      current_channel = user_commands.filter { |cmd| cmd.action == :join }
                                     .map(&:argument)

      outgoing = user_commands.combine_with_latest(current_channel) { |command, channel| command.to_irc_line(channel) }
                              .compact

      outgoing.merge(nick_and_user_msgs).merge(pong)
    end
  end
end