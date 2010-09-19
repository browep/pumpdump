class Quote < ActiveRecord::Base
  attr_accessible :symbol,:market_time,:exchange,:last_price

  include Util
  def market_time_with_zone
    add_hours(self.market_time, -4)
  end
end