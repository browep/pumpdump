require 'simple-rss'
require 'open-uri'

class AdminController < ApplicationController
  def index
    @session_token = session[:auth_token]
    config_token = APP_CONFIG[:auth_token]
        session_token = session[:auth_token]

    @is_admin = config_token == session_token

  end


  def set_auth_token
    @auth_token = params[:auth_token]
    session[:auth_token] = @auth_token
  end

  def contact
    @title = 'Contact'
  end
  
end