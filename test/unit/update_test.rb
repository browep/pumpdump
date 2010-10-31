#require '../lib/update.rb'
require 'test/unit'
require 'date'
require 'test_helper'




class UpdateTester < Test::Unit::TestCase
  include Update
  def test_symbol
    symbol
  end

  def test_update_quotes
    do_quote

  end
end
