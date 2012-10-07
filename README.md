# Foreman

Foreman is a Minecraft server wrapper.

## Logging

Subscribe _logging adapters_ to a `Foreman::Server` to do things with log messages, such as write them to the standard output stream, a file, or a remote logging service. A logging adapter is any object which responds to `log(level, uuid, time, message, options)`:

* `level` -- One of `Foreman::Logging::LEVELS` (`:debug`, `:info`, `:warn`, `:error`, `:fatal`).
* `uuid` -- A unique identifier string for the log message. Useful for identifying the message across different logging systems.
* `time` -- A uniform `Time` for the log message. Useful if you'd like disparate logging adapters to log the message with the same timestamp, even if not all adapters receive the message simultaneously.
* `message` -- The log message.
* `options` -- A hash containing any options originally passed to `Foreman::Server#logger#log`. Useful for attaching structured data to the log message in addition to the human-readable string. A Splunk logging adapter, for instance, might process the contents of `options` as [Splunk event fields](http://docs.splunk.com/Splexicon:Field).

Use `Foreman::Server#logger#subscribe` to subscribe a logging adapter:

```ruby
server = Foreman::Server.new
server.logger.subscribe Foreman::Logging::StdoutAdapter.new
```

If given a block, `subscribe` yields the adapter, which is a useful method of configuration:

```ruby
server = Foreman::Server.new
server.logger.subscribe Foreman::Logging::StdoutAdapter.new do |adapter|
  adapter.level = :debug
end
```

If the logging adapter responds to `subscribed(multiplexer)`, the multiplexer will call that method, passing itself as an argument, after the adapter is subscribed. Adapters can use this to access the logging multiplexer and the Foreman server:

```ruby
class SimpleLoggingAdapter
  def log(level, uuid, time, message, options)
    # ...
  end

  def subscribed(multiplexer)
    @multiplexer = multiplexer # => #<Foreman::Server:0x007fdf72197338 ...>
  end
end
```
