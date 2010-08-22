class EntriesController < ApplicationController
  def index
    @javascript_includes = ["http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js","highcharts"]

    # create the date buckets, just make them 0 - 7
    @day_buckets = 

    @sources = Source.all

    for source in @sources
      #create a new series for each source
      series = []
      entries_per_source = Entry.find(:all,:conditions=>{:source_id=>source.id})

      for entry in entries_per_source

        

      end

    end

    @days = (0..12).to_json
    logger.debug @days
  end

  
  def show
    @entry = Entry.find(params[:id])
  end
  
  def new
    @entry = Entry.new
  end
  
  def create
    @entry = Entry.new(params[:entry])
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
      redirect_to @entry
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
    logger.debug "the symbol #{@symbol}"
    # get all the entries for this
    entries = Entry.find_by_symbol(:order=>"sent_at")

    prices = Quote.find_all_by_symbol(@symbol,:order=>"market_time")

    prices_arr = Array.new
    for price in prices
      prices_arr.push([price.market_time.to_i * 1000, price.last_price])
    end

    @prices_json = prices_arr.to_json
    logger.debug "prices_json:#{@prices_json.to_s}"

  end
end
