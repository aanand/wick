require 'socket'
require 'stream'

module IRCClient
  module Runner
    class Socket
      attr_reader :session

      def initialize(host, port, user_in_io, user_out_io)
        @network_io  = TCPSocket.new(host, port)
        @user_in_io  = user_in_io
        @user_out_io = user_out_io
      end

      def attach(session)
        @session = session

        session.network_out.each do |line|
          @network_io.puts(line)
        end

        session.user_out.each do |line|
          @user_out_io.puts(line)
        end
      end

      def listen!
        session.network_in << "CONNECTION_START"

        while true
          Stream.tick!

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