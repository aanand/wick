require 'stream'

require 'irc_client/message'

module IRCClient
  class Client
    def transform(network_in, user_in)
      messages = network_in.map { |line| Message.parse(line) }

      connection_start = messages.filter { |msg| msg.command == "CONNECTION_START" }
      nick_and_user_msgs = connection_start.flat_map { |_| Stream.from_array(["NICK frippery", "USER frippery () * FRiPpery"]) }

      ping = messages.filter { |msg| msg.command == "PING" }
      pong = ping.map { |msg| "PONG " + msg.params.join(" ") }

      user_in.merge(nick_and_user_msgs).merge(pong)
    end
  end
end