module Foreman
  module Logging
    class StdLibLoggerAdapter
      attr_reader :filters, :logger, :multiplexer

      def initialize(*args)
        @logger = ::Logger.new(*args)
        logger.datetime_format = "%Y-%m-%d %H:%M:%S"
        @filters = []
      end

      def filter(&block)
        filters << block if block_given?
      end

      def level=(level)
        logger.level = level
      end

      def log(level, uuid, time, message, options)
        catch :stop do
          filters.each do |filter|
            filter.call(level, uuid, time, message, options)
          end

          level = ::Logger.const_get(level.to_s.upcase)
          logger.log(level, message)
        end
      end

      def subscribed(multiplexer)
        @multiplexer = multiplexer
      end
    end
  end
end
