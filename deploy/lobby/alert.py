import os

while True:
  if os.path.isfile("/msg/alert"):
    f = open("/msg/alert", "r")
    msg = f.readlines()
    f.close()
    os.remove("/msg/alert")
    message = "\\n\\l"
    for line in msg:
      message= message + line.split("\n")[0] + "\\n\\l"
    for pts in range(10): 
      os.system("printf \"" + message + "\" > /dev/pts/" + str(pts))
