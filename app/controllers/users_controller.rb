class UsersController < ApplicationController

  def home
    @notes = Note.find(owners: BSON::ObjectId(params[:id])).page(params[:page].to_i)
    @cnt_pages=(Note.find(owners: BSON::ObjectId(params[:id])).count.to_f / 10).ceil
  end

  def index
    @users = User.find.page(params[:page].to_i)
    @cnt_pages=(User.find.count.to_f / 10).ceil
  end

  def new
  end

  def create
    user = User.create_one(params[:user])
    if user[:objid]
      redirect_to new_session_path, notice: user[:message]
    else
      flash[:error] = user[:message]
      redirect_to new_user_path
    end
  end

  def edit
  end

  def update
      redirect_to users_path, notice: 'user information updated!'
  end

  def show
  end

  def follow_note
    User.add_followed_note(current_user, params[:note_id])
    redirect_to :back
  end

  def unfollow_note
    User.del_followed_note(current_user, params[:note_id])
    redirect_to :back
  end

  def follow_user
    User.add_followed_note(current_user, params[:user_id])
    redirect_to :back
  end

  def unfollow_user
    User.del_followed_user(current_user, params[:user_id])
    redirect_to :back
  end
end

