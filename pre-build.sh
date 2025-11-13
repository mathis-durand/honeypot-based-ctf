#!/bin/sh

FLAG=$(cat deploy/config/flag)
PASS=$(cat deploy/config/hard_password)

dos2unix deploy/ssh/start.sh
dos2unix deploy/dind/start.sh
dos2unix deploy/lobby/start.sh

echo "Building images"

docker build --build-arg SESSION_ID="$sessionID" -t lobby -f deploy/Dockerfile_lobby deploy/
docker build --build-arg SSH_TYPE=0 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh0 -f deploy/Dockerfile_ssh deploy/ 
docker build --build-arg SSH_TYPE=1 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh1 -f deploy/Dockerfile_ssh deploy/
docker build --build-arg SSH_TYPE=2 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh2 -f deploy/Dockerfile_ssh deploy/
docker build --build-arg SSH_TYPE=3 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh3 -f deploy/Dockerfile_ssh deploy/
docker build --build-arg SSH_TYPE=4 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh4 -f deploy/Dockerfile_ssh deploy/
docker build --build-arg SSH_TYPE=5 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh5 -f deploy/Dockerfile_ssh deploy/
docker build --build-arg SSH_TYPE=6 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh6 -f deploy/Dockerfile_ssh deploy/
docker build --build-arg SSH_TYPE=7 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh7 -f deploy/Dockerfile_ssh deploy/
docker build --build-arg SSH_TYPE=8 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh8 -f deploy/Dockerfile_ssh deploy/

echo "Saving images"
echo "Images Lobby"
docker save lobby -o deploy/images/lobby.tar
echo "Images SSH0"
docker save ssh0 -o deploy/images/ssh0.tar
echo "Images SSH1"
docker save ssh1 -o deploy/images/ssh1.tar
echo "Images SSH2"
docker save ssh2 -o deploy/images/ssh2.tar
echo "Images SSH3"
docker save ssh3 -o deploy/images/ssh3.tar
echo "Images SSH4"
docker save ssh4 -o deploy/images/ssh4.tar
echo "Images SSH5"
docker save ssh5 -o deploy/images/ssh5.tar
echo "Images SSH6"
docker save ssh6 -o deploy/images/ssh6.tar
echo "Images SSH7"
docker save ssh7 -o deploy/images/ssh7.tar
echo "Images SSH8"
docker save ssh8 -o deploy/images/ssh8.tar

