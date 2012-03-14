# encoding: UTF-8
require "mongo_helper"

Note = NoteDB.collection "notes"

def Note.create_one(note, user)
  val = validate_create_note(note); return val unless val[:objid]

  note[:created_at] = note[:updated_at] = Time.now
  nid = Note.insert(note)
  Note.update({_id: nid}, {'$addToSet'=>{owners: BSON::ObjectId(user)}})
  return {objid: nid, message: "note successfully created!"}
end

def Note.update_one(note)
end

def Note.delete_one(note)
  #TODO: delete releated data (note_info,relations,records)
  Note.remove({_id: BSON::ObjectId(note)})
end

def Note.create_one_label(note_id, label)
  val = validate_create_note_label(label); return val unless val[:lid]

  label[:lid] = BSON::ObjectId.new
  # position的赋值是否有更好的实现方法？
  label[:pos] = Note.find_one(_id: BSON::ObjectId(note_id))["labels"].to_a.length + 1
  label[:created_at] = label[:updated_at] = Time.now
  Note.update({_id: BSON::ObjectId(note_id)}, {'$addToSet'=>{labels: label}})
  return {lid: label[:lid], message: "label successfully created!"}
end

def Note.update_one_label(label_id, label)
  val = validate_update_note_label(label); return val unless val[:lid]

  #TODO: 修改实现代码，避免每一个属性进行set，使得能够一句更新所有属性
  Note.update({'labels.lid'=>BSON::ObjectId(label_id)}, {'$set'=>{"labels.$.name"=>label['name'], "labels.$.comment"=>label["comment"], "labels.$.updated_at"=>Time.now}})
  return {lid: label_id, message: "label successfully created!"}
end

def Note.delete_one_label(note_id,label_id)
  #TODO: delete releated data (note_info,records)
  #TODO: 调整label后面的pos值（-1）
  Note.update({_id: BSON::ObjectId(note_id)}, {'$pull'=>{labels: {lid: BSON::ObjectId(label_id)}}})
end

def Note.writable_labels(note, current_user)
  labels_pre = []
  note["labels"].each do |l|
    labels_pre << l if !l["owners"] or l["owners"].blank? or (l["owners"].split.include? current_user)
  end
  labels = labels_pre.sort_by {|l| l["pos"] }
end

def Note.readable_labels(note, current_user)
  labels = note["labels"].sort_by {|l| l["pos"] }
end

private
def validate_create_note(note)
  #TODO: 系统保留不能存入（_开头的名称）
  #TODO: 超出设计字段的情况不能存入
  err_msg=[]
  if note[:name] == "" or note[:name] == nil
    err_msg << "名称不能为空"
  elsif note[:name] =~ /^_/ 
    err_msg << "_开头的名称为系统保留，请使用其它名称。"
  else
  end
  err_msg.empty? ? {objid: true, message: "no error"} : {objid: nil, message: err_msg}
end

def validate_update_note(note)
end

def validate_create_note_label(label)
  #TODO: 超出设计字段的情况不能存入
  #TODO: 重名列不能保存
  #TODO: 系统保留列名
  err_msg=[]
  if label[:name] == "" or label[:name] == nil
    err_msg << "名称不能为空"
  end
  err_msg.empty? ? {lid: true, message: "no error"} : {lid: nil, message: err_msg}
end

def validate_update_note_label(label)
  #TODO: 超出设计字段的情况不能存入
  #TODO: 不能和其它列名一样，提示已存在相同列名
  #TODO: 系统保留列名
  err_msg=[]
  if label[:name] == "" or label[:name] == nil
    err_msg << "名称不能为空"
  end
  err_msg.empty? ? {lid: true, message: "no error"} : {lid: nil, message: err_msg}
end

