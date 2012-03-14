# encoding: utf-8
class NotesController < ApplicationController
  before_filter :if_login?, only: [:new, :create]
  before_filter :note_read?, only: [:show]
  before_filter :note_write?, only: [:edit, :update, :destroy]

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
    @note = Note.find_one({_id: BSON::ObjectId(params[:id])})
  end

  def destroy
    if Note.delete_one(params[:id])
      redirect_to notes_path, notice: "delete note successed!"
    else
      flash[:error] = "delete note failed!"
      redirect_to notes_path
    end
  end

  private
  def note_read?
    note_id = params[:id]
    note = Note.find_one(_id: BSON::ObjectId(note_id))
    return true if note["permission"] == "default" or note["permission"] =~ /public/
    return true if note["permission"] =~ /private/ and current_user and (note["owners"]+note["tusers"].to_a+note["tpusers"].to_a+note["pusers"].to_a).include? BSON::ObjectId(current_user)
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

