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

    def self.parse(line)
      new(line)
    end

    attr_reader :action, :argument

    def initialize(line)
      if match = line.match(REGEX)
        @action   = match[1].downcase.to_sym
        @argument = match[3]
      else
        @action   = nil
        @argument = line
      end
    end

    def to_irc_line(current_channel)
      case action
      when nil
        if current_channel
          "PRIVMSG ##{current_channel} :#{argument}"
        else
          argument
        end
      when :me
        current_channel && "PRIVMSG ##{current_channel} :\x01ACTION #{argument}\x01"
      when :msg
        user, msg = argument.split(/\s+/, 2)
        "PRIVMSG #{user} :#{msg}"
      when :join
        channel = argument
        channel = "##{channel}" unless channel =~ /^#/
        "JOIN #{channel}"
      when :leave, :part
        channel = argument
        channel = "##{channel}" unless channel =~ /^#/
        "PART #{channel}"
      when :quit
        "QUIT :#{argument}"
      when :raw
        argument
      else
        nil
      end
    end
  end
end