# Foreman

Foreman is a Minecraft server wrapper.

## Logging

Foreman's logging mechanism allows you to send Minecraft server log messages to any number of destinations. For instance, you might want to log informative messages such as player joins to a local file, and send debug messages, warnings and errors to [Splunk](http://splunk.com/) for later analysis.

Subscribe _logging adapters_ to a Foreman server to do things with log messages, such as write them to the standard output stream, a file, or a remote logging service. A logging adapter is any object which responds to `log(level, uuid, time, message, options)`:

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

If the logging adapter responds to `subscribed(multiplexer)`, the server's logging multiplexer will call that method, passing itself as an argument, after the adapter is subscribed. Adapters can use this to access the multiplexer and, therefore, the Foreman server:

```ruby
class SimpleLoggingAdapter
  def log(level, uuid, time, message, options)
    # ...
  end

  def subscribed(multiplexer)
    multiplexer.foreman # => #<Foreman::Server:0x007fdf72197338 ...>
  end
end
```

## Watchers

To perform actions in response to server events, Foreman exposes a simple pub-sub interface. To subscribe to the log message feed, call `Foreman::Server#watch` with a human-readable description of what you're watching for and a block, which is passed a `Foreman::Message`, a subscription ID and the `Foreman::Channel` which is distributing the messages.

For example, to log a message when the server is done starting, we'd look for messages like `Done (1.579s)! For help, type "help" or "?"` like this:

```ruby
server = Foreman::Server.new
server.watch "for server startup" do |msg|
  if msg.system? && msg =~ /done/i
    server.logger.info "Minecraft server started"
  end
end
```

Watchers can also unsubscribe themselves from the pub-sub interface:

```ruby
server = Foreman::Server.new
server.watch "for player join" do |msg, id|
  if msg.system? && msg =~ /(\S+) joined/
    username = $~[1]
    server.logger.info "#{username} joined the server"
    foreman.unwatch(id)
  end
end
```
