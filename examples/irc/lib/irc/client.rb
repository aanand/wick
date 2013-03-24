require 'irc/server_event'

module IRC
  class Client
    def initialize(username)
      @username = username
      freeze
    end

    def transform(network_in, user_commands)
      server_events = network_in.skip_start.map { |line| ServerEvent.parse(line) }

      nick_and_user_msgs = network_in.only_start.flat_map { |_| Wick.from_array(["NICK #{@username}", "USER #{@username} () * FRiPpery"]) }

      ping = server_events.filter { |msg| msg.command == "PING" }
      pong = ping.map { |msg| "PONG " + msg.params.join(" ") }

      outgoing = user_commands.map { |cmd|
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

      network_out = outgoing.merge(nick_and_user_msgs).merge(pong)

      server_events.log!("server_events")
      network_out.log!("network_out")

      [network_out, server_events]
    end
  end
end
