require '../lib/util.rb'
require 'test/unit'
require 'date'

require 'test_helper'


class UtilTester < Test::Unit::TestCase
  include Util
  def test_days_ago

    puts " puts"
    days_ago(Date.new - 1)

  end

  def test_in_market_time
#    assert(during_trading_time?(DateTime.new(2010,9,23,9,31)))
#    assert(during_trading_time?(DateTime.new(2010,9,23,9,30)))
#    assert(!during_trading_time?(DateTime.new(2010,9,23,9,29)))
#    assert(!during_trading_time?(DateTime.new(2010,9,23,9,21)))
#    assert(!during_trading_time?(DateTime.new(2010,9,23,16,21)))
#    assert(!during_trading_time?(DateTime.new(2010,9,23,16,0)))
    result = get_symbol_from_text("#HLNT is on a break out ,can only imagine when we recieve word on the dong feng deal -#EIGH is holding gains well -always get in the dips")
    assert("HLNT" == result)
    assert("RMDT" == get_symbol_from_text("Remember who called RMDT as a long play weeks ago at .01!!!! We're up 490% now! Chalk up another Epic pick!"))
    assert("RMDT" == get_symbol_from_text("Remember who called :RMDT as a long play weeks ago at .01!!!! We're up 490% now! Chalk up another Epic pick!"))
    assert("RMDT" == get_symbol_from_text("RMDT as a long play weeks ago at .01!!!! We're up 490% now! Chalk up another Epic pick!"))
    assert("RMDT" == get_symbol_from_text("$RMDT as a long play weeks ago at .01!!!! We're up 490% now! Chalk up another Epic pick!"))
    assert("TRDX" == get_symbol_from_text("Trend Exploration, Inc. (TRDX) Could Bounce Back!! http://f.ast.ly/ATMTX"))
    assert("TRDX" == get_symbol_from_text("Trend Exploration, Inc. TRDX"))

    assert(Entry.SHORT == tim_alert_action({:subject=>"Shorted 6k More CNST at 3.23ish"}))
    assert(Entry.BUY == tim_alert_action({:subject=>"Bought 30k LQMT at 72 cents"}))
    assert(Entry.COVER == tim_alert_action({:subject=>"Covered CNST For Decent Gains"}))
    assert(Entry.SELL == tim_alert_action({:subject=>"Sold 30k LQMT"}))
    assert(Entry.SHORT == tim_alert_action({:subject=>"here is some crap"}))
    assert(Entry.COVER == tim_alert_action({:subject=>"Got Squeezed On CNSt, Playing It Safe"}))

  end


end
