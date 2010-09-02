require '../lib/util.rb'
require 'test/unit'
require 'date'


class UtilTester < Test::Unit::TestCase
  include Util
  def test_days_ago

    puts " puts"
    days_ago(Date.new - 1)

  end

  def test_in_market_time
    assert(during_trading_time?(DateTime.new(2010,9,23,9,31)))
    assert(during_trading_time?(DateTime.new(2010,9,23,9,30)))
    assert(!during_trading_time?(DateTime.new(2010,9,23,9,29)))
    assert(!during_trading_time?(DateTime.new(2010,9,23,9,21)))
    assert(!during_trading_time?(DateTime.new(2010,9,23,16,21)))
    assert(!during_trading_time?(DateTime.new(2010,9,23,16,0)))
  end
end
