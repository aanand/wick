require 'irc_client/session'
require 'irc_client/message'

module IRCClient
  def self.init_session
    session = Session.new

    session.user_in.pipe(session.network_out)

    messages = session.network_in.map { |line| Message.parse(line) }

    connection_start = messages.filter { |msg| msg.command == "CONNECTION_START" }
    nick_and_user_msgs = connection_start.flat_map { |_| Stream.from_array(["NICK frippery", "USER frippery () * FRiPpery"]) }
    nick_and_user_msgs.pipe(session.network_out)

    ping = messages.filter { |msg| msg.command == "PING" }
    pong = ping.map { |msg| "PONG " + msg.params.join(" ") }
    pong.pipe(session.network_out)

    session
  end
end
