module Foreman
  module Logging
    class StdLibLoggerAdapter
      attr_reader :logger, :multiplexer

      def initialize(*args)
        @logger = ::Logger.new(*args)
        logger.datetime_format = "%Y-%m-%d %H:%M:%S"
      end

      def level=(level)
        logger.level = level
      end

      def log(level, uuid, time, message, options)
        level = ::Logger.const_get(level.to_s.upcase)
        logger.log(level, message)
      end

      def subscribed(multiplexer)
        @multiplexer = multiplexer
      end
    end
  end
end
