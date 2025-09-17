import os

while True:
  if os.path.isfile("/msg/alert"):
    f = open("/msg/alert", "r")
    msg = f.readline()
    f.close()
    os.remove("/msg/alert")
    for line in msg.split("\n"):
      for pts in range(10): 
        os.system("echo \"" + line + "\" > /dev/pts/" + str(pts))
