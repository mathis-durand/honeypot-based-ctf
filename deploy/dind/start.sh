#!/bin/sh
set -e

unset DOCKER_HOST

FLAG=$(cat /app/config/flag)
PASS=$(cat /app/config/hard_password)

mkdir -p /logs/-1
mkdir -p /jail//logs
mount --bind /logs/-1 /jail/logs

sessionID=$(bash -c 'uuidgen')
echo "${sessionID}" > /app/dind/.container_id

# Start Docker daemon
dockerd &

sleep 5
# Network
# Check if the 'honeynet' network exists
if ! docker network inspect honeynet >/dev/null 2>&1; then
  # Network doesn't exist, create it
  echo "Network 'honeynet' does not exist. Creating..."
  docker network create --subnet=10.0.0.0/8 --gateway=10.0.0.1 honeynet
  if [ $? -eq 0 ]; then
    echo "Network 'honeynet' created successfully."
  else
    echo "Error creating network 'honeynet'."
    exit 1  # Exit with an error code
  fi
else
  # Network exists
  echo "Network 'honeynet' already exists."
fi

cp /app/config/ssh-key-ctf.pub /app/lobby/

# log folders
mkdir /app/dind/logs
mkdir /msg
mkdir /logs/0
mkdir /logs/1
mkdir /logs/2
mkdir /logs/3
mkdir /logs/4
mkdir /logs/5
mkdir /logs/6
mkdir /logs/7
mkdir /logs/8
echo 0 > /app/dind/.gen

# Build images

docker build --build-arg SESSION_ID="$sessionID" -t lobby /app/lobby
#docker build -t ssh_image /app/ssh
docker build --build-arg SSH_TYPE=0 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh0 /app/ssh
docker build --build-arg SSH_TYPE=1 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh1 /app/ssh
docker build --build-arg SSH_TYPE=2 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh2 /app/ssh
docker build --build-arg SSH_TYPE=3 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh3 /app/ssh
docker build --build-arg SSH_TYPE=4 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh4 /app/ssh
docker build --build-arg SSH_TYPE=5 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh5 /app/ssh
docker build --build-arg SSH_TYPE=6 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh6 /app/ssh
docker build --build-arg SSH_TYPE=7 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh7 /app/ssh
docker build --build-arg SSH_TYPE=8 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh8 /app/ssh
# Start child Dockers
python3 "/app/dind/start-lobby.py"
python3 "/app/dind/start-services.py"

# Start SSH service
# /usr/sbin/sshd -D &

# Start child Dockers
python3 "/app/dind/alarm.py" &


# Keep the container running
tail -f /dev/null

