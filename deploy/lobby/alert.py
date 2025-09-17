import os

while true:
  if os.path.isfile("/msg/alert"):
    f = open("/msg/alert", "r")
    msg = f.readline()
    f.close()
    os.remove("/msg/alert")
    for line in msg.split("\n"):
      pass
