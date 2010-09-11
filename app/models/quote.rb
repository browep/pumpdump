class Quote < ActiveRecord::Base
  attr_accessible :symbol,:market_time,:exchange,:last_price

  include Util
  def market_time_with_zone
    with_zone self.market_time
  end
end