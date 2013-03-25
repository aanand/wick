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

    def run_loop!(&block)
      while true
        tick!
        block.call()
      end
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
