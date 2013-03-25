require 'wick'

module Wick
  module IO
    def self.listen!(readables, writables, &block)
      read_map = {}
      readables.each do |io|
        read_map[io] = Stream.new
      end

      write_streams = block.call(read_map.values)
      write_map = Hash[writables.zip(write_streams)]

      write_map.each_pair do |io, stream|
        stream.skip_start.each do |line|
          io.puts(line)
        end
      end

      read_map.values.each do |stream|
        stream << Wick::START
      end

      Wick.run_loop! do
        ready = ::IO.select(read_map.keys)
        ready[0].each do |io|
          io.read_nonblock(1_000_000).each_line do |line|
            read_map[io] << line
          end
        end
      end
    rescue EOFError
      puts "A connection was closed. Shutting down."
    end
  end
end