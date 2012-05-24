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

  xy=[5,5]
  [start_x,start_y,spacing_x,spacing_y,length_x,length_y] = [120,60,120,120,80,80]
  locations = {}
  zindex=0
  $("#content").css({"height":"600px"})

  find_locations_key_by_id = (id,locs) ->
    result = []
    for key,value of locs
      result=key if value["id"]==id
    result

  game_finished = (locs) ->
    cnt_demand_consistent = 5
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
            #alert col_set
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
      true
    else
      false

  for y in [0..xy[1]-1]
    for x in [0..xy[0]-1]
      loc_id = x+"_"+y
      loc_left = start_x+spacing_x*x
      loc_top  = start_y+spacing_y*y
      temp_colors=[]
      [temp_colors[0],temp_colors[1],temp_colors[2],temp_colors[3],temp_colors[4]]=["red","blue","black","yellow","gray"]
      $("#content_main").append "<div id=#{loc_id} class=#{temp_colors[y]}> <p>#{x+','+y}</p> </div>"
      $("##{loc_id}").css({"width":"#{length_x}px","height":"#{length_y}px","padding":"0.5em","float":"left","background-color":temp_colors[y],"z-index":"1"})
      $("##{loc_id}").offset({"left":loc_left,"top":loc_top})
      locations[[x,y]] = {id:x+"_"+y,loc:$("##{loc_id}").offset(),color:$("##{loc_id}").attr("class")}
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
            $("##{locations[current_loc_key].id}").fadeOut()
            $("##{locations[current_loc_key].id}").offset(locations[moved_loc_key].loc)
            $("##{locations[current_loc_key].id}").fadeIn()
            $(this).fadeOut()
            $(this).offset(locations[current_loc_key].loc)
            $(this).fadeIn()
            #$(this).animate({opacity: 0.25})
            [locations[current_loc_key].id,locations[moved_loc_key].id] = [@id,locations[current_loc_key].id]
            [locations[current_loc_key].color,locations[moved_loc_key].color] = [locations[moved_loc_key].color,locations[current_loc_key].color]
            if game_finished(locations)
              alert "you are awesome!"
            else
              #alert "try again"
          else
            $(this).offset(locations[moved_loc_key].loc)

