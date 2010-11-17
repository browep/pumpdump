require 'core'

class EntriesController < ApplicationController
  before_filter :is_admin,:only=>[:new,:create,:show,:edit,:list]
  include Core

  def index

    @title = "Stocks In Play"

    # get the latest insert,
    latest_factor = Factor.find(:first,:order=>"created_at DESC")
    # get everything within one hour of that one
    factors = Factor.find(:all,:conditions=>["created_at > ?", add_hours(latest_factor.created_at, -1)])

    # create a set, replacing only if timestamp is later
    @symbols = []
    factor_set = {}
    factors.each do |_factor|
      if !factor_set[_factor.symbol]
        factor_set[_factor.symbol] = _factor
        @symbols << {:factor=>_factor}
      end
    end

    # sort the symbols by the most recent factor
    @symbols = @symbols.sort { |a,b|
      b[:factor].factor <=> a[:factor].factor
    }

    # keep the highest
    @symbols = @symbols[0..45]


    # get all the recent mentions, and count their sources

    entries = Entry.find_last_seven_days()
    # construct all the symbols into a hash
    @symbols_hash = {}
    @symbols.each {|symbol| @symbols_hash[symbol[:factor].symbol] = symbol}

    for entry in entries
      hash                        = @symbols_hash[entry.symbol]
      hash = {} unless !hash.nil?
      hash[:count]                = hash[:count].nil? ? 1 : hash[:count] + 1
      set                         = hash[:source_count]
      set = Set.new unless !set.nil?
      set.add(entry.source.id)
      hash[:source_count]         = set
      @symbols_hash[entry.symbol] = hash
    end

    #now put them back into an array
    @symbols.each do |symbol|
      symbol[:count] = @symbols_hash[symbol[:factor].symbol][:count]
      symbol[:source_count] = @symbols_hash[symbol[:factor].symbol][:source_count]
    end


    @recent_entries = Entry.find(:all,:select=>"symbol,source_id",:order=>"sent_at DESC",:limit=>45)
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

    prices_arr = Array.new
    @min_price = nil
    for price in prices
      prices_arr.push([price.market_time_with_zone.to_f.to_i * 1000, price.last_price])
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
    (0..@search_time).reverse_each do  | days_ago|
      time    = add_hours(Time.now, -24 * days_ago)
      _factor = factor(@symbol, time)
      puts _factor
      factors << [time.to_f.to_i*1000,_factor]
    end

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
