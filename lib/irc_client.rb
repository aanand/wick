require 'irc_client/session'
require 'irc_client/runner/socket'
require 'stream'

module IRCClient
  def self.start(options)
    session        = Session.new
    session.runner = Runner::Socket.new(options)

    session.network_in.map { |line|
      "Got line from network: #{line.inspect}"
    }.pipe(session.user_out)

    session.network_out.map { |line|
      "Sending line over network: #{line.inspect}"
    }.pipe(session.user_out)

    session.user_in.pipe(session.network_out)

    connection_start = session.network_in.filter { |line| line == "CONNECTION_START" }
    nick_and_user_msgs = connection_start.map { |line| "NICK frippery\nUSER frippery () * FRiPpery" }
    nick_and_user_msgs.pipe(session.network_out)

    session.start
  end
end
