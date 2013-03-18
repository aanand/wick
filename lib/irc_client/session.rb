module IRCClient
  class Session
    attr_reader :network_in, :network_out,
                :user_in,    :user_out

    attr_accessor :runner

    def initialize
      @network_in  = Stream.new
      @network_out = Stream.new
      @user_in     = Stream.new
      @user_out    = Stream.new
    end

    def start
      runner.start(@network_in, @network_out, @user_in, @user_out)
    end
  end
end