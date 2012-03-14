# encoding: utf-8
module ApplicationHelper
  def header_menu
    menu = ""
    case request.path
    when root_path
      menu += "<a href=#{notes_path}>所有表</a>"
      menu += "&nbsp;&nbsp;<a href=#{users_path}>所有用户</a>"
      if current_user
        menu += "&nbsp;&nbsp;<a href=#{home_user_path(current_user)}>我的表</a>"
        menu += "&nbsp;&nbsp;<a href=#{new_note_path}>新建表</a>"
      end
    when home_user_path
      user_id=request.path.split("/")[2]

      menu += "<a href=#{notes_path}>所有表</a>"
      menu += "&nbsp;&nbsp;<a href=#{users_path}>所有用户</a>"
      if current_user and user_id == current_user then
        menu += "&nbsp;&nbsp;<a href=#{following_notes_user_path(current_user)}>我关注的表</a>"
        menu += "&nbsp;&nbsp;<a href=#{following_user_path(current_user)}>我关注的表用户</a>"
        menu += "&nbsp;&nbsp;<a href=#{new_note_path}>新建表</a>"
      else
        menu += "&nbsp;&nbsp;<a href=#{following_notes_user_path(user_id)}>ta关注的表</a>"
        menu += "&nbsp;&nbsp;<a href=#{following_user_path(user_id)}>ta关注的用户</a>"
      end
    when notes_path
      menu += "<a href=#{users_path}>所有用户</a>"
      if current_user
        menu += "&nbsp;&nbsp;<a href=#{home_user_path(current_user)}>我的表</a>"
        menu += "&nbsp;&nbsp;<a href=#{following_notes_user_path(current_user)}>我关注的表</a>"
        menu += "&nbsp;&nbsp;<a href=#{following_user_path(current_user)}>我关注的表用户</a>"
        menu += "&nbsp;&nbsp;<a href=#{new_note_path}>新建表</a>"
      end
    when note_path
      id = request.path.split("/")[2]

      if if_note_write?(id)
        menu += "<a href=#{edit_note_path(id)}>编辑表信息</a>&nbsp;&nbsp;"
      end
      menu += "<a href=#{note_records_path(id)}>表数据页</a>"
      menu += "&nbsp;&nbsp;<a href=#{note_labels_path(id)}>表的列信息</a>"
    when users_path
      menu += "<a href='/users'>所有用户</a>"
      if current_user
        menu += "&nbsp;&nbsp;<a href=#{home_user_path(current_user)}>我的表</a>"
        menu += "&nbsp;&nbsp;<a href=#{following_notes_user_path(current_user)}>我关注的表</a>"
        menu += "&nbsp;&nbsp;<a href=#{following_user_path(current_user)}>我关注的表用户</a>"
        menu += "&nbsp;&nbsp;<a href=#{new_note_path}>新建表</a>"
      end
    when user_path
      id = request.path.split("/")[2]

      menu += "<a href=#{notes_path}>所有表</a>"
      menu += "&nbsp;&nbsp;<a href=#{users_path}>所有用户</a>"
      if current_user
        menu += "&nbsp;&nbsp;<a href=#{home_user_path(current_user)}>我的表</a>"
        menu += "&nbsp;&nbsp;<a href=#{following_notes_user_path(current_user)}>我关注的表</a>"
        menu += "&nbsp;&nbsp;<a href=#{following_user_path(current_user)}>我关注的表用户</a>"
      end
    when note_records_path
      note_id=request.path.split("/")[2]

      menu += "<a href='/users'>所有用户</a>"
      menu += "&nbsp;&nbsp;<a href=#{note_path(note_id)}>查看表信息</a>"
      menu += "&nbsp;&nbsp;<a href=#{note_labels_path(note_id)}>查看列信息</a>"
      if current_user
        menu += "&nbsp;&nbsp;<a href=#{new_note_record_path(note_id)}>新增数据</a>"
      end
    when note_record_path
      note_id=request.path.split("/")[2]
      id=request.path.split("/")[4]

      menu += "<a href=#{note_records_path(note_id)}>返回表</a>"
      menu += "&nbsp;&nbsp;<a href=#{edit_note_record_path(note_id)}>编辑记录</a>"
      menu += "&nbsp;&nbsp;<a data-method='delete' href=#{note_record_path(note_id, id)}>删除记录</a>"
    when note_labels_path
      id = request.path.split("/")[2]

      menu += "<a href=#{note_path(id)}>查看表信息</a>"
      menu += "&nbsp;&nbsp;<a href=#{note_records_path(id)}>表数据页</a>"
      menu += "&nbsp;&nbsp;<a href=#{new_note_label_path(note_id)}>新建列</a>"
    when note_label_path
      note_id = request.path.split("/")[2]
      id=request.path.split("/")[4]

      menu += "<a href=#{note_records_path(note_id)}>返回表</a>"
      menu += "&nbsp;&nbsp;<a href=#{edit_note_label_path(note_id, id)}>编辑列信息</a>"
      menu += "&nbsp;&nbsp;<a data-method='delete' href=#{note_label_path(note_id, id)}>删除列</a>"
    when new_note_label_path
      note_id = request.path.split("/")[2]
      id=request.path.split("/")[4]

      menu += "<a href=#{note_path(note_id)}>查看表信息</a>"
      menu += "&nbsp;&nbsp;<a href=#{note_labels_path(note_id)}>返回表</a>"
    else
    end
    menu
  end

  def user_menu
    menu = ""
    if current_user
      menu += "<a href=#{home_user_path(current_user)}>#{current_user_email}</a><BR/>"
      menu += "<div class='user_menu'>"
      menu += "<a href=#{edit_user_path(current_user)}>Setting</a><BR/>"
      menu += "<a href=#{logout_path}>Logout</a><BR/>"
      menu += "</div>"
    else
      menu += "<a href=#{login_path}>Login</a>"
      menu += " / "
      menu += "<a href=#{sign_up_path}>Sign up</a>"
    end
    menu
  end
 
  def other_user_notice
    result = ""
    unless current_user
      uid=request.path.split("/")[2]
      if uid.to_s.length == 24
        if user = User.find_one(_id: BSON::ObjectId(uid))
          result += "<div id='content_top'>"
          result += "正在查看用户: #{user["email"]} 的信息<BR/>"
          result += "</div>"
        end
      end
    end
    result
  end
  
  def pagination(cnt_pages, params)
    result = ""
    result += "<div class='pagination'>"
    if cnt_pages > 1 then
      cnt_pages.times do |i|
        result += "[" if (params[:page].nil? and i==0) or params[:page].to_i==i+1
        result += "<a href=#{request.path}?page=#{i+1}>#{i+1}</a>"
        result += "]" if (params[:page].nil? and i==0) or params[:page].to_i==i+1
        result += " "
      end
    end
    result += "</div>"
    result
  end

end
