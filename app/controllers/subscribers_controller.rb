require 'util'

class SubscribersController < ApplicationController
  include Util
  def new
    @subscriber = Subscriber.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subscriber }
    end
  end

  # GET /subscribers/1/edit
  def edit
    @subscriber = Subscriber.find(params[:id])
  end

  # POST /subscribers
  # POST /subscribers.xml
   def create
    # look for subscriber with this email already
    @skip_flash = true
    found = Subscriber.find_by_address(params[:subscriber][:address])
    if found
      flash[:error] = "The email address \"#{params[:subscriber][:address]}\" has already been subscribed."
    else
      @subscriber = Subscriber.new(params[:subscriber])
      if @subscriber.save
        flash[:notice] = "You have been successfully subscribed."
      else
        @subscriber.errors.each do |attr_name,message|
          attr_name = "email address" unless attr_name.to_s != "address"
          flash[:error] = "I'm sorry, #{attr_name} #{message}"
        end

      end
    end
    redirect_to root_url

   end

  def destroy
    #check to make sure the signature matches
    if params[:signature] == sign_text(params[:id].to_s)
      @subscriber = Subscriber.find(params[:id])
      @subscriber.destroy
      flash[:notice] = "#{@subscriber.address} has been successfully unsubscribed."
    else
      flash[:error] ="signatures did not match, please contact us if there was an error."
    end
    redirect_to root_url
  end

end
