require 'irc_event'

module Nice
  class Client
    def initialize(username)
      @username = username
      freeze
    end

    def transform(network_in, user_commands)
      server_events = network_in.map { |line| IRCEvent.parse(line) }

      nick_and_user = Wick.from_array(["NICK #{@username}", "USER #{@username} () * FRiPpery"])

      ping = server_events.select { |msg| msg.command == "PING" }
      pong = ping.map { |msg| "PONG " + msg.params.join(" ") }

      outgoing = process_user_commands(user_commands)

      network_out = outgoing.merge(nick_and_user).merge(pong)

      server_events.log!("server_events")
      network_out.log!("network_out")

      [network_out, server_events]
    end

    def process_user_commands(user_commands)
      user_commands.map { |cmd|
        case cmd.action
        when nil
          if cmd.channel
            "PRIVMSG #{cmd.channel} :#{cmd.argument}"
          else
            cmd.argument
          end
        when :me
          cmd.channel && "PRIVMSG #{cmd.channel} :\x01ACTION #{cmd.argument}\x01"
        when :msg
          "PRIVMSG #{cmd.channel} :#{cmd.argument}"
        when :join
          "JOIN #{cmd.channel}"
        when :part
          "PART #{cmd.channel}"
        when :quit
          "QUIT :#{cmd.argument}"
        when :raw
          cmd.argument
        else
          nil
        end
      }.compact
    end
  end
end
