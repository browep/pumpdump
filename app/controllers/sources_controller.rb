class SourcesController < ApplicationController
  before_filter :is_admin,:only=>[:new,:create,:show,:edit,:list]

  def index
    @title = "Sources"
    @sources = Source.all
  end

  def list
    @title = "Sources"
    @sources = Source.all
  end

  def show

    @source = Source.find(params[:id])

    # get all the entries for this source
    for entry in @source.entries

    end
  end
  
  def new
    @source = Source.new
  end
  
  def create
    @source = Source.new(params[:source])
    if @source.save
      flash[:notice] = "Successfully created source."
      redirect_to @source
    else
      render :action => 'new'
    end
  end
  
  def edit
    @source = Source.find(params[:id])
  end
  
  def update
    @source = Source.find(params[:id])
    if @source.update_attributes(params[:source])
      flash[:notice] = "Successfully updated source."
      redirect_to @source
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @source = Source.find(params[:id])
    @source.destroy
    flash[:notice] = "Successfully destroyed source."
    redirect_to sources_url
  end
end
