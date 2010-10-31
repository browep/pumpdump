class EntriesController < ApplicationController
  before_filter :is_admin,:only=>[:new,:create,:show,:edit,:list]

  def index

    @title = "Stocks In Play"
    entries = Entry.find_last_seven_days()
    @symbols = Hash.new
    for entry in entries
      if @symbols[entry.symbol].nil?
        hash = Hash.new
        set = Set.new
        set.add(entry.source.id)
        hash[:weight] = entry.source.weight
        hash[:count] = 1
        hash[:source_count] = set
        @symbols[entry.symbol] = hash
      else
        hash = @symbols[entry.symbol]
        hash[:weight] = hash[:weight] + entry.source.weight
        hash[:count] = hash[:count] + 1;
        set = hash[:source_count]
        set.add(entry.source.id)
        hash[:source_client] = set

      end
    end

    # sort by highest factor
    @symbols = @symbols.sort { |a,b|
      b[1][:weight] <=> a[1][:weight]
    }

    @recent_entries = Entry.find(:all,:order=>"sent_at DESC",:limit=>75)
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


    prices = Quote.find_all_by_symbol(@symbol,:order=>"market_time",:conditions=>
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
