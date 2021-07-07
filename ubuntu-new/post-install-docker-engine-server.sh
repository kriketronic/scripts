#!/bin/bash

#zona horaria
timedatectl set-timezone America/Argentina/Buenos_Aires

#update apt
apt-get update

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

echo "INSTALLING PORTAINER ...."
docker pull portainer/portainer-ce:latest
docker stop PRD-Portainer-local
docker rm PRD-Portainer-local
docker run -d -p 8000:8000 -p 9000:9000 --name=PRD-Portainer-local --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

