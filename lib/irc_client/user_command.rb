module IRCClient
  class UserCommand
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

    def self.parse(line, channel)
      new(line, channel)
    end

    attr_reader :action, :argument, :channel

    def initialize(line, channel)
      line = line.chomp

      @channel = channel

      if match = line.match(REGEX)
        @action   = match[1].downcase.to_sym
        @argument = match[3]
      else
        @action   = nil
        @argument = line
      end
    end
  end
end