require '../lib/update.rb'
require 'test/unit'
require 'date'


class UpdateTester < Test::Unit::TestCase
  include Update
  def test_symbol
    symbol
  end
end
