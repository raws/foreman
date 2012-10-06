module EventMachine
  class StderrHandler < EventMachine::Connection
    def initialize(connection)
      @connection = connection
    end

    def receive_data(data)
      @connection.receive_data(data)
    end
  end

  def self.popen3(*args)
    original_stderr = $stderr.dup
    read, write = IO.pipe
    $stderr.reopen(write)
    connection = EM.popen(*args)
    $stderr.reopen(original_stderr)
    EM.attach(read, StderrHandler, connection)
    connection
  end
end
