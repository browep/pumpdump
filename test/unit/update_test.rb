#require '../lib/update.rb'
require 'test/unit'
require 'date'
require 'test_helper'




class UpdateTester < Test::Unit::TestCase
  include Update
  include Core
  def test_symbol
    symbol
  end

  def test_update_quotes
    do_quote

  end

  def test_factor
    (0..10).reverse_each do |days_ago|
      _factor = factor("SPPH",add_hours(Time.now, -24 * days_ago))
      puts _factor
    end
  end

  def test_all_factor
    update_all_factors
  end
end
