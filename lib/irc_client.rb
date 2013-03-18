require 'irc_client/session'
require 'irc_client/output/basic'
require 'irc_client/runner/socket'
require 'stream'

module IRCClient
  def self.start(options)
    session = Session.new

    session.user_in.pipe(session.network_out)

    connection_start = session.network_in.filter { |line| line == "CONNECTION_START" }
    nick_and_user_msgs = connection_start.map { |line| "NICK frippery\nUSER frippery () * FRiPpery" }
    nick_and_user_msgs.pipe(session.network_out)

    ping = session.network_in.filter { |line| line =~ /^PING / }
    pong = ping.map { |line| "PONG " + line[/:.*/] }
    pong.pipe(session.network_out)

    output = Output::Basic.new
    output.start(session)

    runner = Runner::Socket.new(options)
    runner.start(session)
  end
end
