require 'core'

class EntriesController < ApplicationController
  before_filter :is_admin,:only=>[:new,:create,:show,:edit,:list]
  include Core

  def index

    @title = "Stocks In Play"

    # get the latest insert,
    latest_factor = Factor.first(:order=>"created_at DESC")
    # get everything within one hour of that one
    created_at_limit = add_hours(latest_factor.created_at, -1)
    factors = Factor.all(:conditions=>["created_at > ?", created_at_limit],:order=>"created_at DESC")

    # create a set, replacing only if timestamp is later
    @symbols = []
    factor_set = {}
    factors.each do |_factor|
      if factor_set[_factor.symbol].nil?
        factor_set[_factor.symbol] = _factor
        @symbols << {:factor=>_factor.factor,:symbol=>_factor.symbol}
      end
    end

    # sort the symbols by the most recent factor
    @symbols = @symbols.sort { |a,b|
      b[:factor] <=> a[:factor]
    }

    # keep the highest
    @symbols = @symbols[0..45]

    # get entries for last 30 days, and their distinct source count
    @symbols.each do |symbol|
      sql  = "SELECT COUNT(DISTINCT source_id) from entries where symbol = '#{symbol[:symbol]}' AND sent_at > '#{time_to_sql_timestamp(add_days(DateTime.now,-30))}'"
      resp = Entry.connection.execute(sql)
      symbol[:source_count] = resp.to_a[0][0]
      sql  = "SELECT COUNT(*) from entries where symbol = '#{symbol[:symbol]}' AND sent_at > '#{time_to_sql_timestamp(add_days(DateTime.now,-30))}'"
      resp = Entry.connection.execute(sql)
      symbol[:count] = resp.to_a[0][0]

    end



    @recent_entries = Entry.all(:select=>"symbol,source_id,sent_at",:order=>"sent_at DESC",:limit=>45)
  end

  
  def show
    @entry = Entry.find(params[:id])
  end
  
  def new
    @entry = Entry.new
  end
  
  def create
    @entry = Entry.new(params[:entry])
    @entry.message_type = Entry.EMAIL
    @entry.guid = "manual-"+rand(100000).to_s
    @entry.source = Source.find(params[:source][:id])
    if @entry.save
      flash[:notice] = "Successfully created entry."
      redirect_to @entry
    else
      render :action => 'new'
    end
  end
  
  def edit
    @entry = Entry.find(params[:id])
  end
  
  def update
    @entry = Entry.find(params[:id])
    if @entry.update_attributes(params[:entry])
      flash[:notice] = "Successfully updated entry."
      redirect_to :action => "list"
    else
      render :action => 'edit'
    end
  end

  def destroy
    @entry = Entry.find(params[:id])
    @entry.destroy
    flash[:notice] = "Successfully destroyed entry."
    redirect_to entries_url
  end

  def symbol
    @javascript_includes = ["jquery","jquery.flot","jquery.flot.stack"]
    @symbol = params[:id]
    @title = @symbol

    if !params[:search_time].nil?
      @search_time = params[:search_time].to_i
    else
      @search_time = 7
    end
    # get all the entries for this


    prices = Quote.find_all_by_symbol(@symbol,:select=>"market_time,last_price",:order=>"market_time",:conditions=>
      ["market_time > ?",DateTime.now - @search_time])


    # get the earliest price, we need to make sure we get a factor at that time to fill out the graph
    earliest_graph_item = nil
    if !prices.nil? && prices.size > 0
      earliest_graph_item = prices[0].market_time_with_zone
    end

    prices_arr = Array.new
    @min_price = nil
    for price in prices
      prices_arr.push([price.market_time_with_zone.to_f.to_i * 1000, price.last_price.to_f])
      if @min_price.nil? || @min_price > price.last_price
        @min_price = price.last_price
      end
    end

    if @min_price.nil?
      @min_price = 0
    else
      @min_price = @min_price * 0.98
    end

    @prices_json = prices_arr.to_json
    logger.debug "prices_json:#{@prices_json.to_s}"

    # get all the entries
    @entries = Entry.find_all_by_symbol(@symbol,:order=>"sent_at",:conditions=>
      ["sent_at > ?",DateTime.now - @search_time])

    entries_arr = []
    buy_arr = []
    sell_arr =[]
    @has_direction = false
    for entry in @entries
      if entry.action.nil?
        entries_arr.push([entry.sent_at_on_graph.to_f.to_i * 1000,entry.source.weight])
      elsif entry.action == Entry.BUY || entry.action == Entry.COVER
        @has_direction = true
        buy_arr.push([entry.sent_at_on_graph.to_f.to_i * 1000,entry.source.weight])
      elsif entry.action == Entry.SELL || entry.action == Entry.SHORT
        @has_direction = true
        sell_arr.push([entry.sent_at_on_graph.to_f.to_i * 1000,entry.source.weight])
      end
    end



    factors = []
    # new stock factor line
    # do one for every day, plus the earliest entry or quote
    factor_times = []
    times_for_factors = (0..@search_time).to_a
#    factor_times << earliest_graph_item
    times_for_factors.reverse_each {|days_ago| factor_times << add_hours(Time.now, -24 * days_ago) }

    # do a factor for each
    factor_times.each do |time|
      _factor = factor(@symbol, add_hours(time,-4))
      factors << [add_hours(time,-8).to_f.to_i*1000,_factor]
    end

    # mixin all factors found in the db
    # only get ones that are at least newer than the oldest factor we just computed
    earliest_factor_time    = add_hours(Time.now, -24 * @search_time)
    db_factors = Factor.find_all_by_symbol(@symbol,:conditions=>["created_at > ? ",time_to_sql_timestamp(earliest_factor_time)])
    db_factors.each do |_factor|
      factors << [(add_hours(_factor.created_at,-5).to_f.to_i * 1000),_factor.factor]
    end

    factors.sort! { |a,b| a[0]<=>b[0]}



    @factors_json = factors.to_json
    @entries_json = entries_arr.to_json
    @buys_json = buy_arr.to_json
    @sells_json = sell_arr.to_json
  end

  def email
    @entry = Entry.find(params[:id])
  end

  def list
    @entries = Entry.all(:order=>"sent_at DESC")
  end
end
