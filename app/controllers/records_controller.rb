# encoding=utf-8
class RecordsController < ApplicationController
  before_filter :record_creatable?, only: [:new, :create]
  before_filter :record_writable?, except: [:index, :show, :new, :create]

  def index
    unless note=Note.find_one({_id: BSON::ObjectId(params[:note_id])}, {fields: {labels: 1, _id: 0}}) and note["labels"]
      flash[:error] = "表暂时没有任何列，需要先添加列再操作相应数据"
      redirect_to new_note_label_path(params[:note_id])
      return true
    end

    @note_id = params[:note_id]
    @note = Note.find_one({_id: BSON::ObjectId(@note_id)})
    @labels = Note.readable_labels(@note, current_user)
    case records_scope(@note_id, @note)
    when "all"
      @records = Record.find({nid: BSON::ObjectId(@note_id)}).sort([["updated_at", "descending"]]).page(params[:page].to_i)
      @cnt_records = Record.find({nid: BSON::ObjectId(@note_id)}).count
      @cnt_pages=(@cnt_records.to_f / 10).ceil
    when "mine"
      @records = Record.find({nid: BSON::ObjectId(@note_id), uid: BSON::ObjectId(current_user)}).sort([["updated_at", "descending"]]).page(params[:page].to_i)
      @cnt_records=Record.find({nid: BSON::ObjectId(@note_id), uid: BSON::ObjectId(current_user)}).count
      @cnt_pages=(@cnt_records.to_f / 10).ceil
    else
      flash[:error] = "目前没有权限查看该表数据"
      redirect_to :back rescue redirect_to notes_path
    end
  end

  def new
    @note_id = params[:note_id]
    @note = Note.find_one({_id: BSON::ObjectId(@note_id)})
    @note_name = @note["name"]
    @labels = Note.writable_labels(@note, current_user)
    @record = {}
  end

  def create
    @note_id = params[:note_id]
    record = Record.create_one(@note_id, current_user, params[:record])
    if record[:objid]
      redirect_to note_records_path(@note_id), notice: record[:message]
    else
      flash[:error] = record[:message]
      redirect_to new_note_record_path(@note_id)
    end
  end

  def edit
    @note_id = params[:note_id]
    @note = Note.find_one({_id: BSON::ObjectId(@note_id)})
    @note_name = @note["name"]
    @labels = Note.writable_labels(@note, current_user)
    @id = params[:id]
    @record = Record.find_one({_id: BSON::ObjectId(@id)})
  end

  def update
    @note_id = params[:note_id]
    record = Record.update_one(params[:id], params[:record])
    if record[:objid]
      redirect_to note_records_path(@note_id), notice: record[:message]
    else
      flash[:error] = "record update failed!"
      redirect_to :back
    end
  end

  def show
    @note = Note.find_one({_id: BSON::ObjectId(params[:note_id])})
    @labels = Note.readable_labels(@note, current_user)
    @record = Record.find_one({_id: BSON::ObjectId(params[:id])})
  end

  def destroy
    @note_id = params[:note_id]
    @record_id = params[:id]
    if Record.delete_one(@record_id)
      redirect_to note_records_path(@note_id), notice: "delete record successed!"
    else
      flash[:error] = "delete record failed!"
      redirect_to note_records_path(@note_id)
    end
  end

  private
  def records_scope(note_id, note)
    return "all" if current_user and note["owners"].include?(BSON::ObjectId(current_user))
    case  note["permission"]
    when "default", "public_team", "public_tp"
      "all"
    when "public_personal"
      "mine"
    when "private_team", "private_tp"
      if current_user and note["users"].include?(BSON::ObjectId(current_user))
        "all"
      else
        "none"
      end
    when "private_personal"
      if current_user and note["users"].include?(BSON::ObjectId(current_user))
        "mine"
      else
        "none"
      end
    else
      "none"
    end
  end

  def record_writable?
    note_id = params[:note_id]
    note = Note.find_one({_id: BSON::ObjectId(note_id)})
    record_id = params[:id]
    record = Record.find_one({_id: BSON::ObjectId(record_id)}) if record_id

    return true if current_user and note["owners"].include?(BSON::ObjectId(current_user))
    case note["permission"]
    when "public_team"
      return true
    when "public_tp","public_personal"
      return true if (current_user and (record["uid"].to_s == current_user))
    when "private_team"
      return true if (current_user and note["users"].include?(BSON::ObjectId(current_user)))
    when "private_tp", "private_personal"
      return true if (current_user and note["users"].include?(BSON::ObjectId(current_user)) and (record["uid"].to_s==current_user))
    else
    end
    flash[:error] = "目前没有权限编辑该条数据"
    redirect_to :back rescue redirect_to note_records_path(note_id)
  end

  def record_creatable?
    note_id = params[:note_id]
    note = Note.find_one({_id: BSON::ObjectId(note_id)})

    return true if current_user and note["owners"].include?(BSON::ObjectId(current_user))
    case note["permission"]
    when "public_team","public_tp","public_personal"
      return true if current_user
    when "private_team","private_tp","private_personal"
      return true if current_user and note["users"].include?(BSON::ObjectId(current_user))
    else
    end
    flash[:error] = "目前没有权限添加数据或未登录"
    redirect_to :back rescue redirect_to note_records_path(note_id)
  end
end

