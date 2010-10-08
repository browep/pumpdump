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
  
  def create
    symbols_text = params[:bad_symbol][:symbol]
    bad_symbols = symbols_text.split(",")
    bad_symbols.each do | symbol_param |
      bad_symbol = BadSymbol.new(:symbol=>symbol_param)

      if bad_symbol.save
        flash[:notice] = "Successfully created bad symbols."
        BadSymbol.all.each do |symbol|
          entries = Entry.find_all_by_symbol(symbol.symbol)
          puts "removing for #{symbol.symbol}"
          entries.each do |entry|
            puts "destroying #{entry.id}"
            entry.destroy
          end
        end
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
end
