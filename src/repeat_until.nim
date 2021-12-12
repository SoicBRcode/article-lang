# This template implements repeat: until (true) in nim
template repeatUntil*(a, b: untyped): untyped =
    b
    while not a: b