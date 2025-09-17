import os

while True:
  if os.path.isfile("/msg/alert"):
    f = open("/msg/alert", "r")
    msg = f.readlines()
    f.close()
    os.remove("/msg/alert")
    for line in msg:
      line=line.split("\n")[0]
      for pts in range(10): 
        os.system("echo \"" + line + "\" > /dev/pts/" + str(pts))
