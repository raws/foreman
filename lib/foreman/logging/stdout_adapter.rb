module Foreman
  module Logging
    class StdoutAdapter
      attr_reader :logger, :multiplexer

      def initialize
        @logger = ::Logger.new(STDOUT)
        @logger.datetime_format = "%Y-%m-%d %H:%M:%S"
      end

      def level=(level)
        @logger.level = level
      end

      def log(level, uuid, time, message, options)
        level = ::Logger.const_get(level.to_s.upcase)
        @logger.log(level, [uuid, message, options.inspect].join(" "))
      end

      def subscribed(multiplexer)
        @multiplexer = multiplexer
      end
    end
  end
end
