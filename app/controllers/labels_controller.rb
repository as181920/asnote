# encoding: utf-8
class LabelsController < ApplicationController
  before_filter :label_read?, only: [:index, :show]
  before_filter :label_write?, only: [:new, :create, :edit, :update, :destroy]

  def index
    @note_id = params[:note_id]
    @note = Note.find_one({_id: BSON::ObjectId(@note_id)})
    @max_pos = ((Note.find_one(_id: BSON::ObjectId(params[:note_id]))["labels"].sort_by {|l| l["pos"]}).last)["pos"] 
    @labels = Note.readable_labels(@note, current_user)
  end

  def sort
    @max_pos = ((Note.find_one(_id: BSON::ObjectId(params[:note_id]))["labels"].sort_by {|l| l["pos"]}).last)["pos"] 
    case params["label"]["mv_pos"]
    when "up"
      if params["label"]["c_pos"].to_i > 0
        last_label = Note.find_one(_id: BSON::ObjectId(params[:note_id]))["labels"].find{|label| label["pos"]==params["label"]["c_pos"].to_i and label["deleted"]!=1}
        Note.update({'labels.lid'=>BSON::ObjectId(params["label"]["lid"])}, {'$set'=>{"labels.$.pos"=>params["label"]["c_pos"].to_i}})
        Note.update({'labels.lid'=>last_label["lid"]}, {'$set'=>{"labels.$.pos"=>params["label"]["c_pos"].to_i+1}})
      end
    when "down"
      if params["label"]["c_pos"].to_i < @max_pos - 1
        next_label = Note.find_one(_id: BSON::ObjectId(params[:note_id]))["labels"].find{|label| label["pos"]==params["label"]["c_pos"].to_i+2 and label["deleted"]!=1}
        Note.update({'labels.lid'=>BSON::ObjectId(params["label"]["lid"])}, {'$set'=>{"labels.$.pos"=>params["label"]["c_pos"].to_i+2}})
        Note.update({'labels.lid'=>next_label["lid"]}, {'$set'=>{"labels.$.pos"=>params["label"]["c_pos"].to_i+1}})
      end
    else
    end

    redirect_to :back
  end

  def new
    @note_id = params[:note_id]
    @note_name = Note.find_one({_id: BSON::ObjectId(@note_id)})["name"]
    @label = {}
  end

  def create
    @note_id = params[:note_id]
    label = Note.create_one_label(@note_id, params[:label])
    if label[:lid]
      redirect_to note_labels_path(@note_id), notice: label[:message]
    else
      flash[:error] = label[:message]
      redirect_to new_note_label_path(@note_id)
    end
  end

  def edit
    @note_id = params[:note_id]
    @note = Note.find_one({_id: BSON::ObjectId(@note_id)})
    @note_name = @note["name"]
    @id = params[:id]
    @label = @note["labels"].find{|label| label["lid"]==BSON::ObjectId(@id) }
  end

  def update
    @note_id = params[:note_id]
    if Note.update_one_label(params[:id], params[:label])[:lid]
      redirect_to note_labels_path(@note_id), notice: "label successfully updated!"
    else
      flash[:error] = "label update failed!"
      redirect_to edit_note_label_path(@note_id)
    end
  end

  def show
    @note = Note.find_one({_id: BSON::ObjectId(params[:note_id])})
    @label = @note["labels"].find{|label| label["lid"]==BSON::ObjectId(params[:id]) }
  end

  def destroy
    @note_id = params[:note_id]
    @label_id = params[:id]
    if Note.delete_one_label(@note_id, @label_id)
      redirect_to note_labels_path(@note_id), notice: "delete label successed!"
    else
      flash[:error] = "delete label failed!"
      redirect_to note_labels_path(@note_id)
    end
  end

  private
  def label_read?
    note_id = request.path.split("/")[2]
    #id = request.path.split("/")[4]
    note = Note.find_one(_id: BSON::ObjectId(note_id))
    return true if note["permission"] == "default" or note["permission"] =~ /public/
    return true if note["permission"] =~ /private/ and current_user and (note["owners"]+note["users"].to_a).include? BSON::ObjectId(current_user)
    flash[:error] = "暂时没有权限查看该表的列信息"
    redirect_to :back rescue redirect_to notes_path
  end

  def label_write?
    note_id = request.path.split("/")[2]
    #id = request.path.split("/")[4]
    note = Note.find_one(_id: BSON::ObjectId(note_id))
    return true if current_user and note["owners"].include? BSON::ObjectId(current_user)
    flash[:error] = "暂时没有权限编辑该表的列信息"
    redirect_to :back rescue redirect_to note_path(note_id)
  end
end

