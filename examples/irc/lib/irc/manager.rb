module IRC
  class Manager
    def initialize(client, ui)
      @client = client
      @ui = ui
      freeze
    end

    def transform(network_in, user_in)
      server_events_bus = Wick::Bus.new
      user_commands_bus = Wick::Bus.new

      network_out, server_events = @client.transform(network_in, user_commands_bus)
      user_out,    user_commands = @ui.transform(user_in, server_events_bus)

      server_events_bus.consume!(server_events)
      user_commands_bus.consume!(user_commands)

      [network_out, user_out]
    end
  end
end

