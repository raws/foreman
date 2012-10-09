module Foreman
  class Channel < EventMachine::Channel
    # Add one or more items to the channel, which are pushed out to all subscribers. In contrast
    # with EventMachine's native Channel, this implementation passes the subscriber's
    # subscription ID and the channel as block arguments, enabling a subscriber to easily
    # unsubscribe itself.
    #
    # @example
    #   foreman.watch do |message, id|
    #     # Do some one-off work
    #     foreman.unwatch id
    #   end
    # @example
    #   foreman.watch do |message, id, channel|
    #     # Do some one-off work
    #     channel.unsubscribe id
    #   end
    def push(*items)
      items = items.dup
      EventMachine.schedule do
        items.each do |item|
          @subs.each do |subscription_id, callable|
            callable.call item, subscription_id, self
          end
        end
      end
    end
  end
end
