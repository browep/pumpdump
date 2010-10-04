class TestController < ApplicationController
  before_filter :is_debug

  include Update

  def is_debug
    APP_CONFIG[:debug] || APP_CONFIG[:debug] == "true"

  end

  def symbol

    do_symbol
    render "default"
  end

end
