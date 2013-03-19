require 'irc_client/session'

module IRCClient
  def self.init_session
    session = Session.new

    session.user_in.pipe(session.network_out)

    connection_start = session.network_in.filter { |line| line == "CONNECTION_START" }
    nick_and_user_msgs = connection_start.map { |line| "NICK frippery\nUSER frippery () * FRiPpery" }
    nick_and_user_msgs.pipe(session.network_out)

    ping = session.network_in.filter { |line| line =~ /^PING / }
    pong = ping.map { |line| "PONG " + line[/:.*/] }
    pong.pipe(session.network_out)

    session
  end
end
