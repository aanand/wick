require 'irc_client/runner/socket'
require 'stream'

module IRCClient
  def self.start(options)
    Session.new(options).start
  end

  class Session
    def initialize(options)
      network_in  = Stream.new
      network_out = Stream.new
      user_in     = Stream.new
      user_out    = Stream.new

      network_in.each do |line|
        user_out << "Got line from network: #{line.inspect}"
      end

      user_in.each do |line|
        user_out << "Got line from user input: #{line.inspect}"
      end

      options = options.merge(
        network_in:  network_in,
        network_out: network_out,
        user_in:     user_in,
        user_out:    user_out
      )

      Runner::Socket.new(options).start
    end
  end
end
