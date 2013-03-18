require 'socket'

module IRCClient
  module Runner
    class Socket
      def initialize(options)
        @network_io  = TCPSocket.new(options.fetch(:host), options.fetch(:port))
        @user_in_io  = options.fetch(:user_in_io)  { $stdin  }
        @user_out_io = options.fetch(:user_out_io) { $stdout }
      end

      def start(network_in, network_out, user_in, user_out)
        network_out.each do |line|
          @network_io.puts(line)
        end

        user_out.each do |line|
          @user_out_io.puts(line)
        end

        network_in << "CONNECTION_START"

        while true
          ready = IO.select([@network_io, @user_in_io])
          ready[0].each do |io|
            if io == @network_io
              io.read_nonblock(1_000_000).each_line do |line|
                network_in << line
              end
            elsif io == @user_in_io
              io.read_nonblock(1_000_000).each_line do |line|
                user_in << line
              end
            end
          end
        end

        network.close
      end
    end
  end
end