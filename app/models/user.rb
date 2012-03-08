# encoding: UTF-8
require "mongo_helper"

User = NoteDB.collection "users"

def User.create_one(user)
  val = validate_signup_user(user); return val unless val[:objid]

  user[:salt] = BCrypt::Engine.generate_salt
  user[:encrypted_password] = BCrypt::Engine.hash_secret(user[:password], user[:salt])
  user.delete :password
  user.delete :password_confirmation
  user[:created_at] = user[:updated_at] = Time.now
  uid = User.insert(user)
  return {objid: uid, message: "user successfully created!"}
end

def User.authenticate(email,submitted_password)
  user = User.find_one(email: email)
  (user && user["encrypted_password"] == BCrypt::Engine.hash_secret(submitted_password,user["salt"])) ? user : nil
end

def User.add_followed_note(user_id, note_id)
  #TODO: 验证关注的表是否重复，不存在等异常情况
  User.update({_id: BSON::ObjectId(user_id)}, {'$addToSet' => {fnotes: BSON::ObjectId(note_id)}})
end

def User.followed_note?(user_id, note_id)
  User.find_one({_id: BSON::ObjectId(user_id)},{fields: {fnotes: 1, _id: 0}})["fnotes"].to_a.include? BSON::ObjectId(note_id)
end

def User.del_followed_note(user_id, note_id)
  User.update({_id: BSON::ObjectId(user_id)}, {'$pull' => {fnotes: BSON::ObjectId(note_id)}})
end

def User.add_followed_user(user_id, fuser_id)
  User.update({_id: BSON::ObjectId(user_id)}, {'$addToSet' => {fusers: BSON::ObjectId(fuser_id)}})
end

def User.followed_user?(user_id, fuser_id)
  User.find_one({_id: BSON::ObjectId(user_id)},{fields: {fusers: 1, _id: 0}})["fusers"].to_a.include? BSON::ObjectId(fuser_id)
end

def User.del_followed_user(user_id, fuser_id)
  User.update({_id: BSON::ObjectId(user_id)}, {'$pull' => {fusers: BSON::ObjectId(fuser_id)}})
end

private
def validate_signup_user(user)
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  err_msg=[]
  #TODO: 用户属性不能超出页面设置的范围－禁止用户通过技术方法增加其余字段
  if user[:email] == "" or user[:email] == nil
    err_msg << "邮箱不能为空"
  elsif !(user[:email]=~email_regex)
    err_msg << "邮件格式不正确"
  #TODO: 邮箱唯一性检查需要重构
  elsif User.find_one(email: user[:email])
    err_msg << "该邮箱已被注册"
  end
  if user[:password] == "" or user[:password] == nil
    err_msg << "密码不能为空"
  #elsif user[:password].length<6
  #  err_msg << "密码至少6位"
  #elsif user[:password_confirmation]== "" or user[:password_confirmation] == nil
  #  err_msg << "请输入确认密码"
  elsif user[:password]!=user[:password_confirmation]
    err_msg << "2次密码输入不一致"
  end
  err_msg.empty? ? {objid: true, message: "no error"} : {objid: nil, message: err_msg}
end

