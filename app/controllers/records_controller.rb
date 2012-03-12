# encoding=utf-8
class RecordsController < ApplicationController
  before_filter :check_permission_write?, except: [:index, :show]

  def index
    unless Note.find_one({_id: BSON::ObjectId(params[:note_id])}, {fields: {labels: 1, _id: 0}})["labels"]
      flash[:error] = "should add labels and then add record!"
      redirect_to new_note_label_path(params[:note_id])
      return true
    end

    @note_id = params[:note_id]
    @note = Note.find_one({_id: BSON::ObjectId(@note_id)})
    @note_labels = @note["labels"].sort_by {|l| l["pos"] }
    case check_permission_type(@note_id)
    when "owner"
      @records = Record.find({nid: BSON::ObjectId(@note_id)}).page(params[:page].to_i)
      @cnt_pages=(Record.find({nid: BSON::ObjectId(@note_id)}).count.to_f / 10).ceil
    when "team_team"
    when "team_personal"
    when "public_personal"
      @records = Record.find({nid: BSON::ObjectId(@note_id), uid: BSON::ObjectId(current_user)}).page(params[:page].to_i)
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
    @labels = @note["labels"].sort_by {|l| l["pos"] }
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
    @labels = @note["labels"].sort_by {|l| l["pos"] }
    @record = Record.find_one({_id: BSON::ObjectId(params[:id])})
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
end

