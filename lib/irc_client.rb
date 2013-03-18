require 'socket'
require 'stream'

class IRCClient
  def self.start(options)
    new(options).start
  end

  def initialize(options)
    incoming = Stream.new

    incoming.each do |line|
      puts "Got line: #{line.inspect}"
    end

    open_socket(options[:host], options[:port], incoming)
  end

  def open_socket(host, port, incoming)
    s = TCPSocket.new(host, port)

    while line = s.gets
      incoming << line
    end

    s.close
  end
end