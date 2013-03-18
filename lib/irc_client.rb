require 'irc_client/session'
require 'irc_client/runner/socket'
require 'stream'

module IRCClient
  def self.start(options)
    session        = Session.new
    session.runner = Runner::Socket.new(options)

    session.network_in.each do |line|
      session.user_out << "Got line from network: #{line.inspect}"
    end

    session.network_out.each do |line|
      session.user_out << "Sending line over network: #{line.inspect}"
    end

    session.user_in.each do |line|
      session.network_out << line
    end

    connection_start = session.network_in.filter { |line| line == "CONNECTION_START" }
    nick_and_user_msgs = connection_start.map { |line| "NICK frippery\nUSER frippery () * FRiPpery" }
    nick_and_user_msgs.pipe(session.network_out)

    session.start
  end
end
