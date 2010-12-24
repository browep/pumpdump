require "test/unit"
require "util"

class UtilTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end


  def test_add_minutes
    include Util
    datetime = DateTime.new(2010,12,22,4,22,00)
    assert(datetime.min == 22)
    datetime = add_minutes(datetime, -15)
    assert(datetime.min == 7)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_fail

    # To change this template use File | Settings | File Templates.
    fail("Not implemented")
  end
end