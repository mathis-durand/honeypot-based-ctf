#!/bin/sh

FLAG=$(cat deploy/config/flag)
PASS=$(cat deploy/config/hard_password)

dos2unix deploy/ssh/start.sh
dos2unix deploy/dind/start.sh
dos2unix deploy/lobby/start.sh


docker build --build-arg SESSION_ID="$sessionID" -t lobby deploy/Dockerfile_lobby
docker save lobby -o deploy/lobby/lobby.tar

docker build --build-arg SSH_TYPE=0 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh0 deploy/Dockerfile_ssh 
docker save ssh0 -o deploy/ssh/ssh0.tar
docker build --build-arg SSH_TYPE=1 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh1 deploy/Dockerfile_ssh
docker save ssh1 -o deploy/ssh/ssh1.tar
docker build --build-arg SSH_TYPE=2 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh2 deploy/Dockerfile_ssh
docker save ssh2 -o deploy/ssh/ssh2.tar
docker build --build-arg SSH_TYPE=3 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh3 deploy/Dockerfile_ssh
docker save ssh3 -o deploy/ssh/ssh3.tar
docker build --build-arg SSH_TYPE=4 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh4 deploy/Dockerfile_ssh
docker save ssh4 -o deploy/ssh/ssh4.tar
docker build --build-arg SSH_TYPE=5 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh5 deploy/Dockerfile_ssh
docker save ssh5 -o deploy/ssh/ssh5.tar
docker build --build-arg SSH_TYPE=6 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh6 deploy/Dockerfile_ssh
docker save ssh6 -o deploy/ssh/ssh6.tar
docker build --build-arg SSH_TYPE=7 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh7 deploy/Dockerfile_ssh
docker save ssh7 -o deploy/ssh/ssh7.tar
docker build --build-arg SSH_TYPE=8 --build-arg FLAG="$FLAG" --build-arg PASS="$PASS" -t ssh8 deploy/Dockerfile_ssh
docker save ssh8 -o deploy/ssh/ssh8.tar

