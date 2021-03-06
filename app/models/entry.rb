require 'util'

class Entry < ActiveRecord::Base
  belongs_to :source
  has_one :email_content
  attr_accessible :symbol,:sent_at,:guid,:url,:message_type,:action,:body,:content


  extend Util
  extend Core
  
  def sent_at_with_zone
    if self.message_type == type_twitter
      add_hours(self.sent_at, 1)
    else
      add_hours(self.sent_at, 0)
    end
  end

  def self.find_last_seven_days
    find(:all,:select=>"sent_at,id,symbol,source_id", :order=>"sent_at", :conditions=>
              ["sent_at > ?", DateTime.now - 7])
  end

  def self.find_last_30_days
    find(:all,:select=>"sent_at,id,symbol,source_id", :order=>"sent_at", :conditions=>
              ["sent_at > ?", DateTime.now - 30])
  end

  def self.find_distinct_in_last_30_days
    all(:select=>"DISTINCT(symbol)",  :conditions=>
              ["sent_at > ?", DateTime.now - 30])
  end

  def sent_at_on_graph
    if self.message_type == type_twitter
      add_hours(self.sent_at, -3)
    else
      add_hours(self.sent_at, -4)
    end

  end

  def self.BUY
    0
  end

  def self.SHORT
    1
  end

  def self.SELL
    2
  end

  def self.COVER
    3
  end

  def self.TWITTER
    0
  end

  def self.EMAIL
    1
  end

  def action_display_name
    if self.action == Entry.BUY
      "buy"
    elsif self.action == Entry.SHORT
      "short"
    elsif self.action == Entry.COVER
      "cover"
    elsif self.action == Entry.SELL
      "sell"
    end
  end

  def self.get_quotes(symbol, search_time)
    include Util
    prices = Quote.find_all_by_symbol(symbol, :select=>"market_time,last_price", :order=>"market_time", :conditions=>
        ["market_time > ?", DateTime.now - search_time])

    prices_arr = Array.new
    min_price = nil
    for price in prices
      prices_arr.push([price.market_time_with_zone.to_f.to_i * 1000, price.last_price.to_f])
      if min_price.nil? || min_price > price.last_price
        min_price = price.last_price
      end
    end

    if min_price.nil?
      min_price = 0
    else
      min_price = min_price * 0.98
    end

    factors = []
    # mixin all factors found in the db
    # only get ones that are at least newer than the oldest factor we just computed
    earliest_factor_time = add_hours(Time.now, -24 * search_time)
    db_factors = Factor.find_all_by_symbol(symbol, :conditions=>["created_at > ? ", time_to_sql_timestamp(earliest_factor_time)])
    db_factors.each do |_factor|
      factors << [(add_hours(_factor.created_at, -5).to_f.to_i * 1000), _factor[:factor]]
    end

    factors.sort! { |a, b| a[0]<=>b[0] }

    return factors,min_price,prices_arr

  end


end