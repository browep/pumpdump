class BadSymbolsController < ApplicationController

  before_filter :is_admin

  def index
    @bad_symbols = BadSymbol.all
  end
  
  def show
    @bad_symbol = BadSymbol.find(params[:id])
  end
  
  def new
    @bad_symbol = BadSymbol.new
  end

  def remove_all_from_bad_symbol(bad_symbol)
    entries = Entry.find_all_by_symbol(bad_symbol)
    puts "removing for #{bad_symbol}"
    entries.each do |entry|
      puts "destroying #{entry.id}"
      entry.destroy
    end
  end

  def create
    symbols_text = params[:bad_symbol][:symbol]
    bad_symbols = symbols_text.split(",")
    bad_symbols.each do | symbol_param |
      bad_symbol = BadSymbol.new(:symbol=>symbol_param,:verified=>true)
      if bad_symbol.save
        flash[:notice] = "Successfully created bad symbols."
        remove_all_from_bad_symbol(bad_symbol.symbol)
      end
    end
    redirect_to :action => "new"
  end
  
  def edit
    @bad_symbol = BadSymbol.find(params[:id])
  end
  
  def update
    @bad_symbol = BadSymbol.find(params[:id])
    if @bad_symbol.update_attributes(params[:bad_symbols])
      flash[:notice] = "Successfully updated bad symbols."
      redirect_to @bad_symbol
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @bad_symbol = BadSymbol.find(params[:id])
    @bad_symbol.destroy
    flash[:notice] = "Successfully destroyed bad symbols."
    redirect_to bad_symbols_url
  end

  def to_verify
    @symbols = BadSymbol.find_all_by_verified(false,:order=>"created_at DESC")

  end

  def verify
    symbol = BadSymbol.find(params[:id])
    if symbol.update_attribute(:verified,true)
      flash[:notice] = "Successfully removed #{symbol.symbol}"
      remove_all_from_bad_symbol(symbol.symbol)
    end

    redirect_to :action => "to_verify"
  end
end
