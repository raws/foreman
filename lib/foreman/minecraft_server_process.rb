module Foreman
  class MinecraftServerProcess < EventMachine::Protocols::LineAndTextProtocol
    attr_reader :foreman

    def initialize(foreman)
      @foreman = foreman
      @unbound = EventMachine::DefaultDeferrable.new
    end

    def receive_data(line)
      line.strip!
      foreman.logger.debug line, direction: :in

      if received_data_is_interesting?(line)
        foreman.logger.info line, direction: :in
      end
    end
    alias :receive_stderr :receive_data

    def send(line)
      line = line.to_s.strip
      foreman.logger.info line, direction: :out
      send_data "#{line}\n"
    end

    def stop(&block)
      @unbound.callback(&block) if block_given?
      send "stop"
    end

    def unbind
      exit_status = get_status.exitstatus
      if exit_status == "0"
        foreman.logger.info "Minecraft server stopped"
      else
        foreman.logger.warn "Minecraft server stopped with exit status #{exit_status}",
          fields: { exit_status: exit_status }
      end
      @unbound.succeed(exit_status)
    end

    private

    def received_data_is_interesting?(line)
      line !~ /\A(?:[\s>]*|.{,1})\Z/
    end
  end
end
