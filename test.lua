micro = GetPartFromPort(1, "Microcontroller")
speaker = GetPartFromPort(2, "Speaker")
speaker:Chat(tostring(micro:GetMethods()["Communicate"][1]))