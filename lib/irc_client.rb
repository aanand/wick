require 'irc_client/session'
require 'irc_client/runner/socket'
require 'stream'

require 'colored'

module IRCClient
  def self.start(options)
    session = Session.new

    session.network_in.map { |data|
      data.strip.each_line.map { |line| "< #{line.strip}".black.bold }
    }.pipe(session.user_out)

    session.network_out.map { |data|
      data.strip.each_line.map { |line| "> #{line.strip}".black.bold }
    }.pipe(session.user_out)

    session.user_in.pipe(session.network_out)

    connection_start = session.network_in.filter { |line| line == "CONNECTION_START" }
    nick_and_user_msgs = connection_start.map { |line| "NICK frippery\nUSER frippery () * FRiPpery" }
    nick_and_user_msgs.pipe(session.network_out)

    runner = Runner::Socket.new(options)
    runner.start(session)
  end
end
