module Nice
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
        action   = match[1].downcase.to_sym
        argument = match[3]
        channel  = nil

        if [:msg, :join, :part].include?(action)
          channel, argument = argument.split(/\s+/, 2)
        end

        new(action, argument, channel)
      else
        new(nil, line, nil)
      end
    end

    def initialize(*args)
      super(*args)
      freeze
    end

    def with_channel(channel_name)
      if channel
        self
      else
        UserCommand.new(action, argument, channel_name)
      end
    end
  end
end
