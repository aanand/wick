require 'wick'

module Wick
  module IO
    def self.bind(options, &block)
      readables_array = [options[:read]].flatten
      writables_array = [options[:write]].flatten

      read_map = {}
      readables_array.each do |io|
        read_map[io] = Stream.new
      end

      block_arg = read_map.values

      write_streams = [block.call(*block_arg)].flatten
      write_map = Hash[writables_array.zip(write_streams)]

      write_map.each_pair do |io, stream|
        stream.each do |line|
          io.puts(line)
        end
      end

      read_map.values.each do |stream|
        stream.start!
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
