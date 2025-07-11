import os

def up_lobby():
  """
  Build and run SSH docker.
  """
  cmd = "docker run"
  cmd+= " -v /logs/-1/:/logs"
  cmd+= " -d"
  cmd+= " --name lobby_c"
  cmd+= " --net honeynet"
  cmd+= " --ip 10.0.0.5"
  cmd+= " -p 2222:2222"
  cmd+= " lobby"
  os.system(cmd)
  pass


up_lobby()
