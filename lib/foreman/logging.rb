module Foreman
  module Logging
    LEVELS = [:debug, :info, :warn, :error, :fatal]

    def self.extract_log_level(input)
      level = nil
      input = input.sub /[^\s\w]*(debug|info|warn(?:ing)?|err(?:or)?|fatal)[^\s\w]*\s+/i do |match|
        level = parse_log_level($~[1])
        "" # Delete entire match from input
      end
      [input, level]
    end

    def self.parse_log_level(input)
      case input.to_s
      when /debug/i then :debug
      when /info/i then :info
      when /warn/i then :warn
      when /err/i then :error
      when /fatal/i then :fatal
      end
    end
  end
end

require "foreman/logging/multiplexer"
require "foreman/logging/std_lib_logger_adapter"
require "foreman/logging/file_adapter"
require "foreman/logging/stdout_adapter"
