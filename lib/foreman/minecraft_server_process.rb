module Foreman
  class MinecraftServerProcess < EventMachine::Protocols::LineAndTextProtocol
    attr_reader :foreman

    def initialize(foreman)
      @foreman = foreman
    end

    def receive_data(line)
      foreman.logger.debug "<<< #{line}"
    end
    alias :receive_stderr :receive_data

    def send(line)
      line = line.to_s.strip
      foreman.logger.debug ">>> #{line}"
      send_data "#{line}\n"
    end
  end
end
