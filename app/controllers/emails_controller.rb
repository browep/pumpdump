class EmailsController < ApplicationController
  def index
    @emails = Email.all
  end
  
  def show
    @email = Email.find(params[:id])
  end
  
  def new
    @email = Email.new
  end
  
  def create
    @email = Email.new(params[:email])
    if @email.save
      flash[:notice] = "Successfully created email."
      redirect_to @email
    else
      render :action => 'new'
    end
  end
  
  def edit
    @email = Email.find(params[:id])
  end
  
  def update
    @email = Email.find(params[:id])
    if @email.update_attributes(params[:email])
      flash[:notice] = "Successfully updated email."
      redirect_to @email
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @email = Email.find(params[:id])
    @email.destroy
    flash[:notice] = "Successfully destroyed email."
    redirect_to emails_url
  end
end
