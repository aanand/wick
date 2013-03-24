module IRC
  class UserCommand < Struct.new(:action, :argument, :channel)
    REGEX = /
      ^
      \/     # leading slash
      (\w+)  # action
      (
        \s+  # space
        (.+) # argument
      )?
      $
    /x

    def self.parse(line)
      line = line.chomp

      if match = line.match(REGEX)
        new(match[1].downcase.to_sym, match[3], nil)
      else
        new(nil, line, nil)
      end
    end

    def initialize(*args)
      super(*args)
      freeze
    end

    def with_channel(channel_name)
      UserCommand.new(action, argument, channel_name)
    end
  end
end
