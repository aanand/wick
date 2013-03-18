require 'socket'
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

  module Runner
    class Socket
      def initialize(options)
        @network_in  = options.fetch(:network_in)
        @network_out = options.fetch(:network_out)
        @user_in     = options.fetch(:user_in)
        @user_out    = options.fetch(:user_out)

        @network_io  = TCPSocket.new(options.fetch(:host), options.fetch(:port))
        @user_in_io  = options.fetch(:user_in_io)  { $stdin  }
        @user_out_io = options.fetch(:user_out_io) { $stdout }
      end

      def start
        @network_out.each do |line|
          @network_io.puts(line)
        end

        @user_out.each do |line|
          @user_out_io.puts(line)
        end

        while true
          ready = IO.select([@network_io, @user_in_io])
          ready[0].each do |io|
            if io == @network_io
              @network_in << io.read_nonblock(1_000_000)
            elsif io == @user_in_io
              @user_in << io.read_nonblock(1_000_000)
            end
          end
        end

        network.close
      end
    end
  end
end
