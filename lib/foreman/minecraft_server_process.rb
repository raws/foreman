module Foreman
  class MinecraftServerProcess < EventMachine::Protocols::LineAndTextProtocol
    attr_reader :foreman

    def initialize(foreman)
      @foreman = foreman
      @unbound = EventMachine::DefaultDeferrable.new
      @unbind_expected = false
    end

    def receive_data(data)
      data.each_line do |line|
        line.strip!
        foreman.logger.debug line, direction: :in

        if received_line_is_useful?(line)
          foreman.logger.info line, direction: :in
        end
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
      @unbind_expected = true
      send "stop"
    end

    def unbind(&block)
      return @unbound.callback(&block) if block_given?
      @unbound.succeed(get_status.exitstatus, @unbind_expected)
    end

    private

    def received_line_is_useful?(line)
      line !~ /\A(?:[\s>]*|.{,1})\Z/
    end
  end
end
