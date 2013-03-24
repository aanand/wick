require 'irc/server_event'

module IRC
  class Client
    def initialize(username)
      @username = username
      freeze
    end

    def transform(network_in, user_commands)
      server_events = network_in.map { |line| ServerEvent.parse(line) }

      connection_start = server_events.filter { |msg| msg.command == "CONNECTION_START" }
      nick_and_user_msgs = connection_start.flat_map { |_| Wick.from_array(["NICK #{@username}", "USER #{@username} () * FRiPpery"]) }

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
          user, msg = cmd.argument.split(/\s+/, 2)
          "PRIVMSG #{user} :#{msg}"
        when :join
          channel = cmd.argument
          channel = "##{channel}" unless channel =~ /^#/
          "JOIN #{channel}"
        when :leave, :part
          channel = cmd.argument
          channel = "##{channel}" unless channel =~ /^#/
          "PART #{channel}"
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