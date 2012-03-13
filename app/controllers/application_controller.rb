# encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  helper_method :current_user_email
  helper_method :if_record_write?
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

  #TODO: 其余note的权限类型
  def if_record_write?(note_id, id)
    note = Note.find_one(_id: BSON::ObjectId(note_id))
    record = Record.find_one(_id: BSON::ObjectId(id))
    return true if note["permission"] == "public_team"
    return true if note["owners"].include? BSON::ObjectId(current_user)
    return true if current_user and record["uid"].to_s == current_user
    false
  end

  def if_login
    session[:original_url] = request.url
    redirect_to login_path, notice: "need login." unless current_user
  end

  def if_owner
    unless current_user and Note.find_one({_id: BSON::ObjectId(params[:id])}, {fields: {owners: 1, _id: 0}})["owners"].to_a.include? BSON::ObjectId(current_user)
      flash[:error] = "you should be owner to edit this note"
      redirect_to note_path(params[:id])
    end
  end
end

