# encoding: utf-8
class NotesController < ApplicationController
  #TODO: p1个类型表权限的实现和优化，
  #TODO: p3表权限类型修改后，原来的权限出了代码是否都ok？
  before_filter :if_login?, only: [:new, :create]
  before_filter :note_read?, only: [:show]
  before_filter :note_write?, except: [:index, :show, :new, :create]

  def index
    @notes = Note.find(permission: {'$nin'=>["private_owner","private_team","private_tp","private_personal"]}, deleted: {'$ne'=>1}).sort([["updated_at", "descending"]]).page(params[:page].to_i)
    @cnt_pages=(Note.find.count.to_f / 10).ceil
  end

  def new
    @note = {}
  end

  def create
    note = Note.create_one(params[:note], current_user)
    if note[:objid]
      redirect_to home_user_path(current_user), notice: note[:message]
    else
      flash[:error] = note[:message]
      redirect_to new_note_path
    end
  end

  def edit
    @id = params[:id]
    @note = Note.find_one({_id: BSON::ObjectId(@id)})
    @note_name = @note["name"]
  end

  def update
    @id = params[:id]
    note = Note.update_one(@id, params[:note])
    if note[:objid]
      redirect_to note_path(params[:id]), notice: note[:message]
    else
      flash[:error] = note[:message]
      redirect_to edit_note_path(@id)
    end
  end

  def show
    @id = params[:id]
    @note = Note.find_one({_id: BSON::ObjectId(@id)})
  end

  def destroy
    if Note.delete_one(params[:id])
      redirect_to notes_path, notice: "delete note successed!"
    else
      flash[:error] = "delete note failed!"
      redirect_to notes_path
    end
  end

  def new_owner
    @id = params[:id]
    @note = Note.find_one({_id: BSON::ObjectId(@id)})
    @note_name = @note["name"]
  end

  def add_owner
    @id = params[:id]
    @email = params[:user][:email]
    owner = Note.create_owner(@id, @email)
    if owner[:uid]
      redirect_to note_path(@id), notice: owner[:message]
    else
      flash[:error] = owner[:message]
      redirect_to new_owner_note_path(@id)
    end
  end

  def new_user
    @id = params[:id]
    @note = Note.find_one({_id: BSON::ObjectId(@id)})
    @note_name = @note["name"]
  end

  def add_user
    @id = params[:id]
    @email = params[:user][:email]
    user = Note.create_user(@id, @email)
    if user[:uid]
      redirect_to note_path(@id), notice: user[:message]
    else
      flash[:error] = user[:message]
      redirect_to new_user_note_path(@id)
    end
  end

  def delete_owner
    @note_id = params[:id]
    @user_id = params[:user_id]

    if Note.delete_owner(@note_id, @user_id)
      redirect_to note_path(@note_id), notice: "表所有者已删除!"
    else
      flash[:error] = "最后一个所有者不可删除，或其它异常!"
      redirect_to note_path(@note_id)
    end
  end

  def delete_user
    @note_id = params[:id]
    @user_id = params[:user_id]

    if Note.delete_user(@note_id, @user_id)
      redirect_to note_path(@note_id), notice: "表普通用户已删除!"
    else
      flash[:error] = "操作发生异常!"
      redirect_to note_path(@note_id)
    end
  end

  private
  def note_read?
    note_id = params[:id]
    note = Note.find_one(_id: BSON::ObjectId(note_id))
    return true if note["permission"] == "default" or note["permission"] =~ /public/
    return true if note["permission"] =~ /private/ and current_user and (note["owners"]+note["users"].to_a).include? BSON::ObjectId(current_user)
    flash[:error] = "暂时没有权限查看该表"
    redirect_to :back rescue redirect_to notes_path
  end

  def note_write?
    note_id = params[:id]
    note = Note.find_one(_id: BSON::ObjectId(note_id))
    return true if current_user and note["owners"].include? BSON::ObjectId(current_user)
    flash[:error] = "暂时没有权限编辑该表"
    redirect_to :back rescue redirect_to notes_path
  end

end

