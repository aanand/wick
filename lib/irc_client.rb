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

    session.user_in.each do |line|
      session.user_out << "Got line from user input: #{line.inspect}"
    end

    session.start
  end
end
