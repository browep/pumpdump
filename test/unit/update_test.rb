#require '../lib/update.rb'
require 'test/unit'
require 'date'
require 'test_helper'
require 'update_quote'



class UpdateTester < Test::Unit::TestCase
  include Update
  include Core
  def test_symbol
    symbol
  end

  def test_update_quotes

    # create new updater
    updater = QuoteUpdater.new({})
    updater.start

  end

  def test_update_one_quote
    updater = QuoteUpdater.new({})
    inserted_quotes = updater.do_some_quotes(1)
    assert(inserted_quotes.size == 1)

  end

  def test_get_quote
    quotes = get_quote(["AAPL","GOOG","LQMT","MSFT","GM","CRAPBLASTERS"])
    assert(quotes.size == 6)
    assert(!quotes["AAPL"].nil? && quotes["AAPL"] > 10)
    assert(!quotes["LQMT"].nil? && quotes["LQMT"] > 0)
    assert(!quotes["CRAPBLASTERS"].nil? && quotes["CRAPBLASTERS"] == 0)

  end

  def test_factor
    (0..10).reverse_each do |days_ago|
      _factor = do_factor("ACTC",add_hours(Time.now, -24 * days_ago))
      puts _factor
    end
  end

  def test_all_factor
    update_all_factors
  end

  def test_yahoo_oauth
    updater = QuoteUpdater.new({})
    results = updater.yahoo_oauth_query(["AAPL","MSFT","CPI","LUKE","CASEY","NOC","TKMR","KHZM","BSX","YEAR","AGDI","GSC","LNET","KMX","NXG","ORFG","LOI","ASA","CABG","CNGI","PKF","CNAM","HCV","SCE","UEC","MCVE","PMXO","DOD","STO","SPPI","DEA","CIBC","ANOC","INUV","ICAD","ARG","XING","PFE","EGI","CNOZ","LXX","ICGN","ARPU","SRGE","IVAN","VCTY","HLNT","AVNA","LPI","GGI","LBSR","RSNA"])
    results
  end
end
