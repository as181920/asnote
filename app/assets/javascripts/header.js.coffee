
$(document).ready ->
  $("#user")
    .bind 'mouseenter', (event,ui) =>
      $(".user_menu").show()
    .bind 'mouseleave', (event,ui) =>
      $(".user_menu").hide()

###
  $("#header")
    .bind 'mouseenter', (event,ui) =>
      $(".header_menu").show()
    .bind 'mouseleave', (event,ui) =>
      $(".header_menu").hide()
###

