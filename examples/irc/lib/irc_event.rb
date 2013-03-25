# Copied from https://github.com/Nerdmaster/ruby-irc-yail/blob/develop/lib/net/yail/message_parser.rb

class IRCEvent
  attr_reader :line, :nick, :user, :host, :prefix, :command, :params, :servername

  USER        = /\S+?/
  NICK        = /[\w\d\\|`'^{}\]\[-]+?/
  HOST        = /\S+?/
  SERVERNAME  = /\S+?/

  # This is automatically grouped for ease of use in the parsing.  Group 1 is
  # the full prefix; 2, 3, and 4 are nick/user/host; 1 is also servername if
  # there was no match to populate 2, 3, and 4.
  PREFIX      = /((#{NICK})!(#{USER})@(#{HOST})|#{SERVERNAME})/
  COMMAND     = /(\w+|\d{3})/
  TRAILING    = /\:\S*?/
  MIDDLE      = /(?: +([^ :]\S*))/

  MESSAGE     = /^(?::#{PREFIX} +)?#{COMMAND}(.*)$/

  def self.parse(line)
    new(line)
  end

  def initialize(line)
    line = line.sub(/[\r\n]+$/, '')

    @line = line
    @params = []

    if line =~ MESSAGE
      matches = Regexp.last_match

      @prefix = matches[1]
      if (matches[2])
        @nick = matches[2]
        @user = matches[3]
        @host = matches[4]
      else
        @servername = matches[1]
      end

      @command = matches[5]

      # Args are a bit tricky.  First off, we know there must be a single
      # space before the arglist, so we need to strip that.  Then we have to
      # separate the trailing arg as it can contain nearly any character. And
      # finally, we split the "middle" args on space.
      arglist = matches[6].sub(/^ +/, '')
      arglist.sub!(/^:/, ' :')
      (middle_args, trailing_arg) = arglist.split(/ +:/, 2)
      @params.push(middle_args.split(/ +/)) if middle_args
      @params.push(trailing_arg) if trailing_arg
      @params.compact!
      @params.flatten!
    end

    freeze
  end
end
