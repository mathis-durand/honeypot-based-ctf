#!/bin/sh
set -e

unset DOCKER_HOST

FLAG=$(cat /app/config/flag)
PASS=$(cat /app/config/hard_password)

sessionID=$(bash -c 'uuidgen')
echo "${sessionID}" > /app/dind/.container_id

# Start Docker daemon
dockerd &

sleep 5
# Network
docker network create --subnet=10.0.0.0/8 --gateway=10.0.0.1 honeynet

# Build images

docker load < /app/lobby/lobby.tar
docker load < /app/ssh/ssh0.tar
docker load < /app/ssh/ssh1.tar
docker load < /app/ssh/ssh2.tar
docker load < /app/ssh/ssh3.tar
docker load < /app/ssh/ssh4.tar
docker load < /app/ssh/ssh5.tar
docker load < /app/ssh/ssh6.tar
docker load < /app/ssh/ssh7.tar
docker load < /app/ssh/ssh8.tar

#docker build --build-arg SESSION_ID="$sessionID" -t lobby /app/lobby
#docker build -t ssh_image /app/ssh
#docker build --build-arg SSH_TYPE=0 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh0 /app/ssh
#docker build --build-arg SSH_TYPE=1 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh1 /app/ssh
#docker build --build-arg SSH_TYPE=2 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh2 /app/ssh
#docker build --build-arg SSH_TYPE=3 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh3 /app/ssh
#docker build --build-arg SSH_TYPE=4 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh4 /app/ssh
#docker build --build-arg SSH_TYPE=5 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh5 /app/ssh
#docker build --build-arg SSH_TYPE=6 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh6 /app/ssh
#docker build --build-arg SSH_TYPE=7 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh7 /app/ssh
#docker build --build-arg SSH_TYPE=8 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh8 /app/ssh


# Start child Dockers
python3 "/app/dind/start-lobby.py"
python3 "/app/dind/start-services.py"
python3 "/app/dind/alarm.py" &


# Keep the container running
tail -f /dev/null

