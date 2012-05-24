$(document).ready ->
  Array::unique = ->
    output = {}
    output[@[key]] = @[key] for key in [0...@length]
    value for key, value of output

  po = (obj,property,func) ->
    str = ""
    for prop of obj
      if typeof(obj[prop]) != 'function'
        if property != false
          str += prop + ":" + obj[prop] + "\n"
        else if func != false
          str += prop + ":" + typeof(obj[prop]) + "\n"
    str

  xy=[3,4]
  [start_x,start_y,spacing_x,spacing_y,length_x,length_y,flg_changed] = [120,60,120,120,80,80,0]
  locations = {}
  zindex=0
  $("#content").css({"height":"550px"})

  find_locations_key_by_id = (id,locs) ->
    result = []
    for key,value of locs
      result=key if value["id"]==id
    result

  game_finished = (locs) ->
    cnt_demand_consistent = 3
    cnt_color_consistent = 0
    skip_start = 0
    skip_step = 0
    #横向
    for y in [0..xy[1]-1]
      skip_step = 0
      for x in [0..xy[0]-1]
        if x <= (xy[0]-cnt_demand_consistent)
          col_set = (locs[[x+i,y]].color for i in [0..cnt_demand_consistent-1])
          if col_set.unique().length == 1
            cnt_color_consistent+=1
            skip_start = x
            skip_step  = cnt_color_consistent
          else
            skip_step = 0
    #纵向
    for x in [0..xy[0]-1]
      skip_step = 0
      for y in [0..xy[1]-1]
        if y <= (xy[1]-cnt_demand_consistent)
          col_set = (locs[[x,y+i]].color for i in [0..cnt_demand_consistent-1])
          if col_set.unique().length == 1
            cnt_color_consistent+=1
            skip_start = y
            skip_step  = cnt_color_consistent
          else
            skip_step = 0
          #if locs[[x,y]].color==locs[[x,y+1]].color and locs[[x,y]].color==locs[[x,y+2]].color and y>=skip_start+skip_step
            #alert [locs[[x,y]].color,locs[[x,y+1]].color,locs[[x,y+2]].color]
    #alert cnt_color_consistent
    if cnt_color_consistent >= parseInt(xy[0]*xy[1]/cnt_demand_consistent)
      alert "you are awesome!"
    false

  for y in [0..xy[1]-1]
    for x in [0..xy[0]-1]
      loc_id = x+"_"+y
      loc_left = start_x+spacing_x*x
      loc_top  = start_y+spacing_y*y
      temp_colors=[]
      [temp_colors[0],temp_colors[1],temp_colors[2],temp_colors[3]]=["red","blue","black","yellow"]
      $("#content_main").append "<div id=#{loc_id} class='ui-widget-content'> <p>#{x+','+y}</p> </div>"
      $("##{loc_id}").css({"width":"#{length_x}px","height":"#{length_y}px","padding":"0.5em","float":"left","background-color":temp_colors[y],"z-index":"1"})
      $("##{loc_id}").offset({"left":loc_left,"top":loc_top})
      locations[[x,y]] = {id:x+"_"+y,loc:$("##{loc_id}").offset(),color:y}
      $("##{loc_id}").draggable
        drag: (event,ui) ->
          $(this).css({"cursor":"move","z-index":zindex+=1})
          $("#footer_detail_msg").text(ui.offset.left+","+ui.offset.top)
        stop: (event,ui) ->
          $(this).css({"cursor":"auto"})
          current_loc_x=parseInt((ui.offset.left+length_x/2-start_x)/spacing_x)
          current_loc_y=parseInt((ui.offset.top+length_y/2-start_y)/spacing_y)

          current_loc_key = current_loc_x+","+current_loc_y
          moved_loc_key  = find_locations_key_by_id @id,locations
          if current_loc_x >=0 and current_loc_x < xy[0] and current_loc_y >=0 and current_loc_y < xy[1] and moved_loc_key!=current_loc_key
            $("##{locations[current_loc_key].id}").offset(locations[moved_loc_key].loc)
            $(this).offset(locations[current_loc_key].loc)
            [locations[current_loc_key].id,locations[moved_loc_key].id] = [@id,locations[current_loc_key].id]
            if game_finished(locations)
              alert "xxx"
            else
          else
            $(this).offset(locations[moved_loc_key].loc)

