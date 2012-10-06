module Foreman
  class Server
    attr_reader :logger, :process

    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::DEBUG
    end

    def start
      @process = EventMachine.popen3 "/usr/local/bin/java7 -Xms4G -Xmx4G -jar Tekkit.jar", MinecraftServerProcess, self
    end
  end
end
