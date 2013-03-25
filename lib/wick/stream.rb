module Wick
  class Stream
    def initialize
      @handlers = []
      @start_callbacks = []
    end

    def <<(data)
      @handlers.each do |handler|
        handler.call(data)
      end
    end

    def each(&handler)
      @handlers << handler
    end

    def at_start
      s = Stream.new
      @start_callbacks.push(proc { s << Wick::START })
      s
    end

    def start!
      @start_callbacks.each(&:call)
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

    def compact
      filter { |msg| not msg.nil? }
    end

    def merge(other)
      s = Stream.new
      self.pipe!(s)
      other.pipe!(s)
      s
    end

    def combine(other, &combiner)
      latest_self  = nil
      latest_other = nil

      s = Stream.new

      self.each do |msg|
        latest_self = msg
        s << combiner.call(msg, latest_other)
      end

      other.each do |msg|
        latest_other = msg
        s << combiner.call(latest_self, msg)
      end

      s
    end

    def sampling(other, &combiner)
      latest_other = nil

      other.each do |msg|
        latest_other = msg
      end

      s = Stream.new

      self.each do |msg|
        s << combiner.call(msg, latest_other)
      end

      s
    end

    def scan(initial, &scanner)
      s = Wick.from_array([initial])
      last = initial
      self.each do |msg|
        last = scanner.call(last, msg)
        s << last
      end
      s
    end

    def log!(prefix)
      self.each do |msg|
        $stderr.puts("[#{prefix}] " + msg.inspect)
      end
      self
    end

    def pipe!(other)
      self.each do |msg|
        other << msg
      end
    end
  end
end
