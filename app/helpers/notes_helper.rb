module NotesHelper
  def note_style(note_id,user_id=current_user)
    rel = Relation_UN.find_one(note_id: BSON::ObjectId(note_id),user_id: BSON::ObjectId(user_id))
    pos = (rel and rel["position"]) ? rel["position"] : {}
    if pos.present?
      "position: absolute; top: #{pos["top"].to_i}px; left: #{pos["left"].to_i}px;"
    else
      #"position: absolute; "
      "display: inline;"
    end
  end

  def notes_list_style
    user_id = params[:id]
    user = User.find_one(_id: BSON::ObjectId(user_id))
    if user and user["home_height"]
      "height: #{user["home_height"].to_s}px"
    else
      ""
    end
  end
end
