module Foreman
  module Logging
    class Multiplexer
      attr_reader :adapters, :filters, :foreman

      def initialize(foreman, adapters = [])
        @foreman = foreman
        @adapters = adapters
        @filters = []
      end

      def filter(&block)
        filters << block if block_given?
      end

      def subscribe(adapter)
        adapters << adapter
        adapter.subscribed(self) if adapter.respond_to?(:subscribed)
        yield adapter if block_given?
      end

      def log(level, message = nil, options = {})
        time = options.delete(:time) || Time.now
        uuid = foreman.uuid.generate

        catch :stop do
          filters.each do |filter|
            filter.call(level, uuid, time, message, options)
          end

          blocks = adapters.map do |adapter|
            lambda do
              adapter.log(level, uuid, time, message, options) if adapter.respond_to?(:log)
            end
          end

          if EventMachine.reactor_running?
            blocks.each do |block|
              EventMachine.defer(&block)
            end
          else
            blocks.each(&:call)
          end
        end
      end

      LEVELS.each do |level|
        define_method(level) do |*args|
          log(level, *args)
        end
      end
    end
  end
end
