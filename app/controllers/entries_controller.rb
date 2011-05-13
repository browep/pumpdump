require 'core'

class EntriesController < ApplicationController
  before_filter :is_admin,:only=>[:new,:create,:show,:edit,:list]
  include Core

  def index

    @title = "Stocks In Play"

    @symbols = Factor.top

    @recent_entries = Entry.all(:select=>"symbol,source_id,sent_at",:order=>"sent_at DESC",:limit=>45)

    @subscriber = Subscriber.new

    @flash_inner = true

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


    factors,@min_price,prices = Entry.get_quotes(@symbol, @search_time)
    @factors_json = factors.to_json
    @prices_json = prices.to_json

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
    @title = Email
    @entry = Entry.find(params[:id])
  end

  def list
    @entries = Entry.all(:order=>"sent_at DESC")
  end


  def chart
    num = params[:id]
    @symbol = Rails.cache.read("symbol_#{num}")
    @factors_json = Rails.cache.read("factors_#{num}").to_json
    @prices_json =   Rails.cache.read("prices_#{num}").to_json
    @min_price =  Rails.cache.read("min_price_#{num}")
    render :layout => false
  end
end
