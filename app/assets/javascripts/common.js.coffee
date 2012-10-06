@po = (obj,property,func) ->
  str = ""
  for prop of obj
    if typeof(obj[prop]) != 'function'
      if property != false
        str += prop + ":" + obj[prop] + "\n"
      else if func != false
        str += prop + ":" + typeof(obj[prop]) + "\n"
  str

