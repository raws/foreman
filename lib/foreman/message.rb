module Foreman
  class Message
    attr_reader :from, :log_level, :original, :parsed

    def initialize(line)
      @original = line
      parse!
    end

    def =~(pattern)
      parsed =~ pattern
    end

    [:chat, :system].each do |type|
      define_method(:"#{type}?") do
        @type == type
      end
    end

    def to_s
      if chat?
        "<#{from}> #{parsed}"
      else
        parsed
      end
    end

    # Return true if the given line is deemed interesting, and not buffer gibberish. This method
    # filters out lines which are empty, input lines which begin with ">", and lines containing only
    # a single character.
    def self.useful?(line)
      line !~ /^\s*$|^[\s>]+|^.{,1}$/
    end

    private

    def parse!
      @parsed = strip_timestamp(original)
      @parsed, @log_level = Logging.extract_log_level(@parsed)

      if @parsed =~ /<([^>]+)>\s*(.*)$/
        @type = :chat
        @from, @parsed = $~[1], $~[2]
      else
        @type = :system
      end
    end

    def strip_timestamp(line)
      line.sub /\A\s*(?:\d+:\d+\s*)+(?::\d+)?\s*/, ""
    end
  end
end
