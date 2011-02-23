class Factor < ActiveRecord::Base
  attr_accessible :symbol,:factor,:created_at
  include Core
  extend Util

  def self.top


    # get the latest insert,
    latest_factor = first(:order=>"created_at DESC")
    # get everything within one hour of that one
    created_at_limit = latest_factor.created_at + -1.hours
    factors = all(:conditions=>["created_at > ?", created_at_limit],:order=>"created_at DESC")

    # create a set, replacing only if timestamp is later
    symbols = []
    factor_set = {}
    factors.each do |_factor|
      if factor_set[_factor.symbol].nil?
        factor_set[_factor.symbol] = _factor
        symbols << {:factor=>_factor['factor'],:symbol=>_factor.symbol}
      end
    end

    # sort the symbols by the most recent factor
    symbols = symbols.sort { |a,b|
      b[:factor] <=> a[:factor]
    }

    # keep the highest
    symbols = symbols[0..45]

    # get entries for last 30 days, and their distinct source count
    symbols.each do |symbol|
      sql  = "SELECT COUNT(DISTINCT source_id) from entries where symbol = '#{symbol[:symbol]}' AND sent_at > '#{time_to_sql_timestamp(DateTime.now + -30.days)}'"
      resp = Entry.connection.execute(sql)
      symbol[:source_count] = resp.to_a[0][0]
      sql  = "SELECT COUNT(*) from entries where symbol = '#{symbol[:symbol]}' AND sent_at > '#{time_to_sql_timestamp(DateTime.now + -30.days)}'"
      resp = Entry.connection.execute(sql)
      symbol[:count] = resp.to_a[0][0]

    end

    symbols
  end

end