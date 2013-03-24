module Wick
  class Bus < Stream
    def consume!(stream)
      stream.pipe!(self)
    end
  end
end

