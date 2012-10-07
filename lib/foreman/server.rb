module Foreman
  class Server
    SHUTDOWN_TIMEOUT = 10

    attr_reader :logger, :process, :uuid

    def initialize
      @logger = Logging::Multiplexer.new(self)
      @uuid = UUID.new
    end

    def start
      @process = EventMachine.popen3 "/usr/local/bin/java7 -Xms4G -Xmx4G -jar Tekkit.jar", MinecraftServerProcess, self
      subscribe_to_process_unbound_event
    end

    def stop(&block)
      process.stop(&block)
    end

    def stopped(exit_status, expected)
      if expected
        logger.info "Minecraft server stopped", fields: { exit_status: exit_status }
        stop_when_all_deferrables_are_complete_or_after_timeout
      else
        logger.warn "Minecraft server stopped unexpectedly. Restarting...",
          fields: { exit_status: exit_status }
      end
    end

    private

    def subscribe_to_process_unbound_event
      process.unbind do |exit_status, expected|
        stopped exit_status, expected
      end
    end

    def stop_when_all_deferrables_are_complete
      if EventMachine.defers_finished?
        EventMachine.stop
      else
        EventMachine.next_tick do
          stop_when_all_deferrables_are_complete
        end
      end
    end

    def stop_when_all_deferrables_are_complete_or_after_timeout
      EventMachine.add_timer(SHUTDOWN_TIMEOUT) { EventMachine.stop }
      stop_when_all_deferrables_are_complete
    end
  end
end
