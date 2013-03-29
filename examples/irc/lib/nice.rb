require 'wick/io'
require 'socket'

require 'nice/client'
require 'nice/ui'
require 'nice/manager'

module Nice
  def self.run!(host, port, nick)
    client  = Client.new(nick)
    ui      = UI.new(nick)
    manager = Manager.new(client, ui)

    socket = TCPSocket.new(host, port)

    Wick::IO.bind(
      read:  [socket, $stdin],
      write: [socket, $stdout]
    ) do |network_in, user_in|
      manager.transform(network_in, user_in)
    end
  end
end
