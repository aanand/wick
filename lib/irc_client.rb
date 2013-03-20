require 'stream'

require 'irc_client/message'
require 'irc_client/user_command'

module IRCClient
  def self.start!(client, output, runner)
    network_in  = Stream.new
    user_in     = Stream.new

    messages      = network_in.map { |line| Message.parse(line)     }
    user_commands = user_in.map    { |line| UserCommand.parse(line) }

    network_out = client.transform(messages, user_commands)
    debug       = self.debug_network(network_in, network_out)
    user_out    = output.transform(messages, user_commands, debug)

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
