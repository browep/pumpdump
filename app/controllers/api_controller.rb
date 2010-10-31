require 'simple-rss'
require 'open-uri'

class ApiController < ApplicationController
  include Update
  def index

  end

  def quote
    puts "starting \"quote\" : #{Time.now.to_s}"
    do_quote
    puts "starting \"quote\" : #{Time.now.to_s}"
    render :text => "OK"

  end

  def symbol
    puts "starting \"symbol\" : #{Time.now.to_s}"
    do_symbol
    puts "ending \"symbol\" : #{Time.now.to_s}"
    render :text => "OK"

  end
end