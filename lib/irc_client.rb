require 'stream'

module IRCClient
  def self.start!(client, output, runner)
    network_in  = Stream.new
    user_in     = Stream.new

    server_events_bus = Stream::Bus.new
    user_commands_bus = Stream::Bus.new

    network_out, server_events = client.transform(network_in, user_commands_bus)
    user_out,    user_commands = output.transform(user_in,    server_events_bus)

    server_events_bus.consume!(server_events)
    user_commands_bus.consume!(user_commands)

    runner.listen!(network_in, network_out, user_in, user_out)
  end

  def self.debug_network(network_in, network_out)
    network_in.flat_map { |data|
      Stream.from_array(data.strip.each_line.map { |line| "< #{line.strip}" })
    }.merge(network_out.flat_map { |data|
      Stream.from_array(data.strip.each_line.map { |line| "> #{line.strip}" })
    })
  end
end
