require 'colored'

module IRCClient
  module Output
    class Basic
      def attach(session)
        session.network_in.map { |data|
          data.strip.each_line.map { |line| "< #{line.strip}".black.bold }
        }.pipe(session.user_out)

        session.network_out.map { |data|
          data.strip.each_line.map { |line| "> #{line.strip}".black.bold }
        }.pipe(session.user_out)
      end
    end
  end
end