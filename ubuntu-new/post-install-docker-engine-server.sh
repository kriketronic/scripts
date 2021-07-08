#!/bin/bash

#zona horaria
timedatectl set-timezone America/Argentina/Buenos_Aires

#update apt
apt-get update

#commons cifs
sudo apt install cifs-utils

#remove old version
apt-get remove docker docker-engine docker.io containerd runc

apt-get  -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io

#set permissions to kike
groupadd docker
usermod -aG docker kike

# Create a SWARM environment
docker swarm init

echo "CREATING NETWORKING"
docker network create --driver overlay proxy-net

echo "INSTALLING TRAEFIC"
docker service create \
    --name proxy \
    --constraint=node.role==manager \
    -p 80:80 \
    -p 9090:8080 \
    --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    --network proxy-net traefik:1.7 \
    --docker \
    --docker.swarmmode \
    --docker.domain=kricomtik-tst.local \
    --docker.watch \
    --api

echo "INSTALLING PORTAINER ...."
docker pull portainer/portainer-ce:latest
sudo docker service create  \
    --name portainer \
    --constraint=node.role==manager \
    --mount type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock \
    --mount type=volume,source=portainer_vol,destination=/data \
    --network proxy-net \
    --label traefik.port=9000 \
    portainer/portainer-ce:latest
