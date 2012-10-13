module Foreman
  module Logging
    class StdoutAdapter < StdLibLoggerAdapter
      def initialize
        super STDOUT
      end

      def log(level, uuid, time, message, options)
        message = [uuid, message, options.inspect].join(" ")
        super level, uuid, time, message, options
      end
    end
  end
end
