require 'wick/io'
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

    Wick::IO.listen!([socket, $stdin], [socket, $stdout]) do |read_streams|
      network_in, user_in = read_streams
      manager.transform(network_in, user_in)
    end
  end
end
