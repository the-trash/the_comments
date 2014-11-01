String::_interpolate = (o) ->
  @replace /{([^{}]*)}/g, (a, b) ->
    r = o[b]
    (if typeof r is "string" or typeof r is "number" then r else a)
