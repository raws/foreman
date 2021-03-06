module Foreman
  class Server
    SHUTDOWN_TIMEOUT = 10

    attr_reader :command, :logger, :messages, :process, :uuid

    def initialize(command)
      @command = command
      @logger = Logging::Multiplexer.new(self)
      @messages = Channel.new
      @uuid = UUID.new
    end

    def start
      logger.debug "Starting Minecraft server...", fields: { command: command }
      @process = EventMachine.popen3 command, MinecraftServerProcess, self
      get_notified_when_process_unbinds
    end

    def stop(&block)
      process.stop(&block)
      exit_after_timeout
    end

    def stopped(exit_status, expected)
      @process = nil
      if expected
        logger.info "Minecraft server stopped", fields: { exit_status: exit_status }
        exit_after_all_deferrables_are_complete
      else
        logger.warn "Minecraft server stopped unexpectedly. Restarting...",
          fields: { exit_status: exit_status }
        start
      end
    end

    def watch(description = nil, &block)
      messages.subscribe block
    end

    def unwatch(subscription_id)
      messages.unsubscribe subscription_id
    end

    private

    def get_notified_when_process_unbinds
      process.unbind do |exit_status, expected|
        stopped exit_status, expected
      end
    end

    def exit_after_all_deferrables_are_complete
      if EventMachine.defers_finished?
        EventMachine.stop
      else
        EventMachine.next_tick do
          exit_after_all_deferrables_are_complete
        end
      end
    end

    def exit_after_timeout
      EventMachine.add_timer(SHUTDOWN_TIMEOUT) do
        EventMachine.stop
      end
    end
  end
end
