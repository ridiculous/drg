module Mobile
  class NotificationPresenter
    extend Forwardable
    attr_reader :context, :notification
    def_delegators :handler,
                   :render, :render_actions

    def initialize(context, notification)
      @context = context
      @notification = notification
    end

    def self.render(*args)
      new(*args).render
    end

    def handler
      @handler ||= new_handler
    end

    def new_handler
      if notification.user_id == context.current_user.id
        Sent.new(self)
      elsif notification.recipient_user_id == context.current_user.id
        Received.new(self)
      else
        # we should never get here
        Null.new(self)
      end
    end
  end
end
