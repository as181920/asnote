class UsersController < ApplicationController

  def home
    #@notes = Note.find(owners: BSON::ObjectId(params[:id])).page(params[:page].to_i)
    #@cnt_pages=(Note.find(owners: BSON::ObjectId(params[:id])).count.to_f / 10).ceil
    @notes = Note.find(owners: BSON::ObjectId(params[:id]), deleted: {'$ne'=>1}).sort("name")
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
    @id = params[:id]
    @user = User.find_one(_id: BSON::ObjectId(@id))
  end

  def follow_note
    User.add_followed_note(current_user, params[:follow_note])
    redirect_to :back
  end

  def unfollow_note
    User.del_followed_note(current_user, params[:follow_note])
    redirect_to :back
  end

  def following_notes
    @notes = []
    User.find_one(_id: BSON::ObjectId(params[:id]))["fnotes"].to_a.each {|id| @notes << Note.find_one(_id: id)}
  end

  def follow
    User.add_followed_user(current_user, params[:follow_user])
    redirect_to :back
  end

  def unfollow
    User.del_followed_user(current_user, params[:follow_user])
    redirect_to :back
  end

  def following
    @users = []
    User.find_one(_id: BSON::ObjectId(params[:id]))["fusers"].to_a.each {|id| @users << User.find_one(_id: id)}
    #@user_ids = User.find_one(_id: BSON::ObjectId(params[:id]))["fusers"]
    #@user_ids.each {|id| @users << User.find_one(_id: id)}
  end
end

