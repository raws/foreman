module Foreman
  module Logging
    class FileAdapter < StdLibLoggerAdapter
      def initialize(path, *options)
        super path, *options
      end

      def log(level, uuid, time, message, options)
        fields = (options[:fields] || {}).merge(uuid: uuid).tap do |fields|
          fields[:direction] = options[:direction].to_s if options[:direction]
        end
        message = "#{message} #{formatted_fields(fields)}"
        super level, uuid, time, message, options
      end

      private

      def formatted_fields(fields)
        fields.inject([]) do |pairs, (key, value)|
          pairs << "#{key}=#{value.inspect}"
        end.join(" ")
      end
    end
  end
end
