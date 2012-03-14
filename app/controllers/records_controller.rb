# encoding=utf-8
class RecordsController < ApplicationController
  before_filter :record_permission_write?, except: [:index, :show]

  def index
    unless note=Note.find_one({_id: BSON::ObjectId(params[:note_id])}, {fields: {labels: 1, _id: 0}}) and note["labels"]
      flash[:error] = "should add labels and then add record!"
      redirect_to new_note_label_path(params[:note_id])
      return true
    end

    @note_id = params[:note_id]
    @note = Note.find_one({_id: BSON::ObjectId(@note_id)})
    @note_labels = @note["labels"].sort_by {|l| l["pos"] }
    #TODO: 优化实现代码
    case record_permission_type(@note_id)
    when "owner","default" , "public_team", "public_tp"
      @records = Record.find({nid: BSON::ObjectId(@note_id)}).sort([["updated_at", "descending"]]).page(params[:page].to_i)
      @cnt_pages=(Record.find({nid: BSON::ObjectId(@note_id)}).count.to_f / 10).ceil
    when "public_personal"
      @records = Record.find({nid: BSON::ObjectId(@note_id), uid: BSON::ObjectId(current_user)}).sort([["updated_at", "descending"]]).page(params[:page].to_i)
      @cnt_pages=(Record.find({nid: BSON::ObjectId(@note_id), uid: BSON::ObjectId(current_user)}).count.to_f / 10).ceil
    else
      flash[:error] = "目前没有权限查看该表数据"
      redirect_to :back
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
  #TODO: 其它note权限类型的处理？
  def record_permission_write?
    note_id = params[:note_id]
    note = Note.find_one({_id: BSON::ObjectId(note_id)})
    owners = note["owners"]
    note_permission_type = record_permission_type(note_id)
    return true if note["permission"] == "public_team"
    if current_user
      record_id = params[:id]
      record = Record.find_one({_id: BSON::ObjectId(record_id)}) if record_id
      if owners.include? BSON::ObjectId(current_user)
        return true
      else
        #TODO: 其它权限类型
        case note_permission_type
        when "public_tp"
          return true if !record_id or record["uid"].to_s == current_user
        when "public_personal"
          return true if !record_id or record["uid"].to_s == current_user
        else
        end
      end
    end
    flash[:error] = "目前没有权限编辑该条数据"
    redirect_to :back rescue redirect_to note_records_path(note_id)
  end

  #TODO: 确认是否需要该方法，以及优化
  def record_permission_type(note_id)
    note = Note.find_one({_id: BSON::ObjectId(note_id)})
    owners = note["owners"]
    return "public_team" if note["permission"] == "public_team"
    if current_user
      if owners.include? BSON::ObjectId(current_user)
        "owner"
      else
        #TODO: 其它权限类型
        case note["permission"]
        when "default"
          "default"
        when "public_tp"
          "public_tp"
        when "public_personal"
          "public_personal"
        else
          "guest"
        end
      end
    else
      "guest"
    end
  end

end

