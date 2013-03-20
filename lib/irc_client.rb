require 'stream'

module IRCClient
  def self.start!(client, output, runner)
    network_in  = Stream.new
    user_in     = Stream.new

    network_out = client.transform(network_in, user_in)
    user_out    = output.transform(network_in, network_out)

    runner.listen!(network_in, network_out, user_in, user_out)
  end
end
