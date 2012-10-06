@locate_note = () =>
  zindex = 0
  $(".note_item").draggable
    #start: (event,ui) ->
    drag: (event,ui) ->
      $(this).css({"cursor":"move","z-index":zindex+=1})
    stop: (event,ui) ->
      $(this).css({"cursor":"auto"})
      note_id = $(this).context.id
      $.ajax
        url: "/notes/#{note_id}/locate"
        type: "post"
        data: {offset_top: $(this).offset().top, offset_left: $(this).offset().left, position_top: $(this).position().top, position_left: $(this).position().left}

