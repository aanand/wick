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

  def filter(&predicate)
    s = Stream.new
    self.each do |msg|
      s << msg if predicate.call(msg)
    end
    s
  end

  def pipe(stream)
    self.each do |msg|
      stream << msg
    end
  end
end
