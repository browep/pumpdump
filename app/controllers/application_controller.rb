require "util"
class ApplicationController < ActionController::Base
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  include Util

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def is_admin
    config_token = APP_CONFIG[:auth_token]
    session_token = session[:auth_token]
    if !(session_token == config_token)
      redirect_to "/"
    end

  end

end
