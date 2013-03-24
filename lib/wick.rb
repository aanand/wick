require 'wick/stream'
require 'wick/bus'

module Wick
  START = Object.new.freeze

  class << self
    def from_array(array)
      s = Stream.new
      on_next_tick do
        array.each do |item|
          s << item
        end
      end
      s
    end

    def listen!(readables, writables, &block)
      read_map = {}
      readables.each do |io|
        read_map[io] = Stream.new
      end

      write_streams = block.call(read_map.values)
      write_map = Hash[writables.zip(write_streams)]

      write_map.each_pair do |io, stream|
        stream.each do |line|
          io.puts(line)
        end
      end

      read_map.values.each do |stream|
        stream << Wick::START
      end

      while true
        tick!

        ready = IO.select(read_map.keys)
        ready[0].each do |io|
          io.read_nonblock(1_000_000).each_line do |line|
            read_map[io] << line
          end
        end
      end
    rescue EOFError
      puts "A connection was closed. Shutting down."
    end

    private

    def on_next_tick(&callback)
      @tick_callbacks ||= []
      @tick_callbacks.push(callback)
    end

    def tick!
      return unless @tick_callbacks
      while callback = @tick_callbacks.shift
        callback.call()
      end
    end
  end
end
