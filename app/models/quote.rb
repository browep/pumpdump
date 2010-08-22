class Quote < ActiveRecord::Base
  attr_accessible :symbol,:market_time,:exchange,:last_price
end