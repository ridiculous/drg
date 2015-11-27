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
end
