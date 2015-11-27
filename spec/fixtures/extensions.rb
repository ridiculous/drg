module Extensions
  def load_and_authorize_item!
    coupon = Coupon.find_by_code(@code)
    if coupon.nil?
      fail Error, "Couldn't find the coupon"
    elsif coupon.cannot_use?
      fail Error, 'Coupon has been used up'
    elsif coupon.expired?
      fail Error, 'Coupon has expired'
    elsif coupon.inactive?
      fail Error, 'Coupon is not activated'
    else
      @item = coupon
    end
  end

  def call
    @called = true
  rescue => e
    puts e
  end

  def go
    begin
      @go = :ok
    rescue StandardError => e
      puts e
    end
  end

  def index
    @title = 'Message Received'
    @finder = Finder.new(params[:id]) { redirect_to(root_path, alert: @finder.error_message) and return }
    @finder.validate!
    @infections = @finder.load_agent(request.user_agent)
    @notification = @finder.notification
  rescue ActiveRecord::RecordNotFound
    @finder.failed
  end
end
