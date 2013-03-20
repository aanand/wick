class Stream
  def initialize
    @handlers = []
  end

  def <<(data)
    @handlers.each do |handler|
      handler.call(data)
    end
  end

  def each(&handler)
    @handlers << handler
  end

  def map(&transformer)
    s = Stream.new
    self.each do |msg|
      s << transformer.call(msg)
    end
    s
  end

  def flat_map(&transformer)
    s = Stream.new
    self.each do |msg|
      transformer.call(msg).pipe!(s)
    end
    s
  end

  def filter(&predicate)
    s = Stream.new
    self.each do |msg|
      s << msg if predicate.call(msg)
    end
    s
  end

  def merge(other)
    s = Stream.new
    self.pipe!(s)
    other.pipe!(s)
    s
  end

  def pipe!(other)
    self.each do |msg|
      other << msg
    end
  end

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
