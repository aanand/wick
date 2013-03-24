require 'wick'
require 'socket'

require 'irc/client'
require 'irc/ui/basic'
require 'irc/ui/nice'
require 'irc/manager'

module IRC
  def self.run!(host, port, nick, basic)
    client  = Client.new(nick)
    ui      = basic ? UI::Basic.new(nick) : UI::Nice.new(nick)
    manager = Manager.new(client, ui)

    socket = TCPSocket.new(host, port)

    Wick.listen!([socket, $stdin], [socket, $stdout]) do |read_streams|
      network_in, user_in = read_streams
      manager.transform(network_in, user_in)
    end
  end

  def self.debug_network(network_in, network_out)
    network_in.flat_map { |data|
      Stream.from_array(data.strip.each_line.map { |line| "< #{line.strip}" })
    }.merge(network_out.flat_map { |data|
      Stream.from_array(data.strip.each_line.map { |line| "> #{line.strip}" })
    })
  end
end
