# encoding: UTF-8
require "mongo_helper"

Note = NoteDB.collection "notes"

def Note.create_one(note, user)
  val = validate_note(note); return val unless val[:objid]

  note[:created_at] = note[:updated_at] = Time.now
  note["owners"] = [BSON::ObjectId(user)]
  nid = Note.insert(note)
  #Note.update({_id: nid}, {'$addToSet'=>{owners: BSON::ObjectId(user)}})
  return {objid: nid, message: "note successfully created!"}
end

def Note.update_one(id, note)
  val = validate_note(note); return val unless val[:objid]

  note[:updated_at] = Time.now
  nid = Note.update({_id: BSON::ObjectId(id)}, {'$set'=>note})
  return {objid: nid, message: "note successfully created!"}
end

def Note.delete_one(note)
  #Note.remove({_id: BSON::ObjectId(note)})
  Note.update({_id: BSON::ObjectId(note)}, {'$set'=>{"deleted"=>1}})
end

def Note.create_one_label(note_id, label)
  val = validate_note_label(label); return val unless val[:lid]

  label[:lid] = BSON::ObjectId.new
  # position的赋值是否有更好的实现方法？
  label[:pos] = Note.find_one(_id: BSON::ObjectId(note_id))["labels"].to_a.find_all{|l| l["deleted"]!=1}.length + 1
  label[:created_at] = label[:updated_at] = Time.now
  Note.update({_id: BSON::ObjectId(note_id)}, {'$addToSet'=>{labels: label}})
  return {lid: label[:lid], message: "label successfully created!"}
end

def Note.update_one_label(label_id, label)
  val = validate_note_label(label); return val unless val[:lid]

  #TODO: 修改实现代码，避免每一个属性进行set，使得能够一句更新所有属性
  Note.update({'labels.lid'=>BSON::ObjectId(label_id)}, {'$set'=>{"labels.$.name"=>label['name'], "labels.$.format"=>label["format"], "labels.$.select"=>label["select"],"labels.$.default"=>label["default"],"labels.$.owners"=>label["owners"] , "labels.$.updated_at"=>Time.now}})
  return {lid: label_id, message: "label successfully created!"}
end

def Note.delete_one_label(note_id,label_id)
  deleted_pos=(Note.find_one(_id: BSON::ObjectId(note_id))["labels"].find{|l| l["lid"].to_s==label_id})["pos"]
  Note.update({'labels.lid'=>BSON::ObjectId(label_id)}, {'$set'=>{"labels.$.deleted"=>1}})
  Note.find_one(_id: BSON::ObjectId(note_id))["labels"].find_all{|l| l["pos"]>deleted_pos}.each do |label|
    label["pos"] -= 1
    Note.update({'_id'=>BSON::ObjectId(note_id),'labels.lid'=>label["lid"]}, {'$set'=>{"labels.$.pos"=>label["pos"]}})
  end
  #Note.update({_id: BSON::ObjectId(note_id)}, {'$pull'=>{labels: {lid: BSON::ObjectId(label_id)}}})
  #Note.update({'_id'=>BSON::ObjectId(note_id),'labels.pos'=>{'$gt'=>deleted_pos}}, {'$inc'=>{"labels.$.pos"=>(-1)}})
end

def Note.writable_labels(note, current_user)
  labels_pre = []
  note["labels"].each do |l|
    unless l["deleted"] == 1
      labels_pre << l if !l["owners"] or l["owners"].blank? or (l["owners"].split.include? current_user)
    end
  end
  labels = labels_pre.sort_by {|l| l["pos"] }
end

def Note.readable_labels(note, current_user)
  labels_pre = []
  note["labels"].each do |l|
    labels_pre << l unless l["deleted"] == 1
  end
  labels = labels_pre.sort_by {|l| l["pos"] }
end

def Note.create_owner(note_id,user_email)
  val = validate_user(user_email); return val unless val[:uid]

  user_id = val[:uid]
  Note.update({_id: BSON::ObjectId(note_id)}, {'$addToSet'=>{owners: BSON::ObjectId(user_id)}})
  return {uid: user_id, message: "表所有者添加成功!"}
end

def Note.delete_owner(note_id, user_id)
  return false if Note.find_one(_id: BSON::ObjectId(note_id))["owners"].to_a.length <= 1
  Note.update({_id: BSON::ObjectId(note_id)}, {'$pull'=>{owners: BSON::ObjectId(user_id)}})
end

def Note.create_user(note_id,user_email)
  val = validate_user(user_email); return val unless val[:uid]

  user_id = val[:uid]
  Note.update({_id: BSON::ObjectId(note_id)}, {'$addToSet'=>{users: BSON::ObjectId(user_id)}})
  return {uid: user_id, message: "表普通用户添加成功!"}
end

def Note.delete_user(note_id, user_id)
  Note.update({_id: BSON::ObjectId(note_id)}, {'$pull'=>{users: BSON::ObjectId(user_id)}})
end

private
def validate_note(note)
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

def validate_note_label(label)
  #TODO: 超出设计字段的情况不能存入
  #TODO: 重名列不能保存
  #TODO: 系统保留列名
  err_msg=[]
  if label[:name] == "" or label[:name] == nil
    err_msg << "名称不能为空"
  end
  err_msg.empty? ? {lid: true, message: "no error"} : {lid: nil, message: err_msg}
end

def validate_user(email)
  err_msg=[]
  user = User.find_one(email: email)
  unless user
    err_msg << "该用户不存在或者无效"
  end
  err_msg.empty? ? {uid: user["_id"].to_s, message: "no error"} : {uid: nil, message: err_msg}
end

