class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  helper_method :current_user_email
  private
  def current_user
    @current_user ||= user_from_session
  end

  def current_user_email
    @current_user_email ||= User.find_one(_id: BSON::ObjectId(current_user))["email"]
  end

  def user_from_session
    user = User.find_one(_id: session[:user_id]) if session[:user_id]
    user["_id"].to_s if user
  end

  def if_login
    session[:original_url] = request.url
    redirect_to login_path, notice: "need login." unless current_user
  end
end

