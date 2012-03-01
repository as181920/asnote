class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  private
  def current_user
    @current_user ||= user_from_session
  end

  def user_from_session
    user = User.find_one(_id: session[:user_id]) if session[:user_id]
    user["_id"].to_s if user
  end
end

