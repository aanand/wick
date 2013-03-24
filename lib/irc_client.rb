require 'wick'

module IRCClient
  def self.debug_network(network_in, network_out)
    network_in.flat_map { |data|
      Stream.from_array(data.strip.each_line.map { |line| "< #{line.strip}" })
    }.merge(network_out.flat_map { |data|
      Stream.from_array(data.strip.each_line.map { |line| "> #{line.strip}" })
    })
  end
end
