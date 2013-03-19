require 'stream'

module IRCClient
  class Session
    attr_reader :network_in, :network_out,
                :user_in,    :user_out

    def initialize
      @network_in  = Stream.new
      @network_out = Stream.new
      @user_in     = Stream.new
      @user_out    = Stream.new
    end
  end
end