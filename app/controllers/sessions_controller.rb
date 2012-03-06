class SessionsController < ApplicationController
  def new
    if current_user then
      redirect_to home_user_path(current_user)
    end
  end

  def create
    user = User.authenticate(params[:user][:email],params[:user][:submitted_password])
    if user then
      session[:user_id] = user["_id"]
      redirect_to (session[:original_url] || home_user_path(current_user)), notice: "Logged in!"
      session[:original_url] = nil
    else
      flash[:error] = "Invalid email or password!"
      redirect_to new_session_path
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "logged out!"
  end
end
