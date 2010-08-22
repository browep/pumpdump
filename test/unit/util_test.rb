#require '../../lib/util'
require 'test/unit'
require 'date'


class UtilTester < Test::Unit::TestCase
  def test_days_ago
    include Util::
    
    puts " puts"
    pp "pp"
     days_ago( DateTime.new+1)

  end
end
