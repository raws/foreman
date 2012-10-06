module Foreman
  class Server
    attr_reader :logger, :process, :uuid

    def initialize
      @logger = Logging::Multiplexer.new(self)
      @uuid = UUID.new
    end

    def start
      @process = EventMachine.popen3 "/usr/local/bin/java7 -Xms4G -Xmx4G -jar Tekkit.jar", MinecraftServerProcess, self
    end

    def stop(&block)
      process.stop(&block)
    end
  end
end
