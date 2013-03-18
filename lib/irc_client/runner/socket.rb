require 'socket'

module IRCClient
  module Runner
    class Socket
      def initialize(options)
        @network_io  = TCPSocket.new(options.fetch(:host), options.fetch(:port))
        @user_in_io  = options.fetch(:user_in_io)  { $stdin  }
        @user_out_io = options.fetch(:user_out_io) { $stdout }
      end

      def start(session)
        session.network_out.each do |line|
          @network_io.puts(line)
        end

        session.user_out.each do |line|
          @user_out_io.puts(line)
        end

        session.network_in << "CONNECTION_START"

        while true
          ready = IO.select([@network_io, @user_in_io])
          ready[0].each do |io|
            if io == @network_io
              io.read_nonblock(1_000_000).each_line do |line|
                session.network_in << line
              end
            elsif io == @user_in_io
              io.read_nonblock(1_000_000).each_line do |line|
                session.user_in << line
              end
            end
          end
        end
      rescue EOFError
        puts "Either stdin or network connection was closed. Shutting down."
      ensure
        @network_io.close
      end
    end
  end
end