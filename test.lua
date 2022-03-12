touch = GetPartFromPort(1, "TouchScreen")
speaker = GetPartFromPort(2, "Speaker")
print(typeof(touch:GetMethods()["GetCursor"]))