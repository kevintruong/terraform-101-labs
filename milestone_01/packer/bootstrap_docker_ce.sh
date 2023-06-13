#!/bin/sh

# Install Docker CE Ubuntu AMI

# set -e

sudo apt-get remove docker docker-engine

sudo apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker ubuntu

sudo systemctl enable docker

docker --version

docker run --restart=always -d -p 8080:8088 -e "SUPERSET_SECRET_KEY=qwerty123" --name superset apache/superset

docker exec superset superset fab create-admin \
  --username admin \
  --firstname Superset \
  --lastname Admin \
  --email admin@superset.com \
  --password admin

docker exec superset superset db upgrade
docker exec superset superset load_examples
docker exec superset superset init

#docker exec -it superset superset fab create-admin \
#              --username admin \
#              --firstname Superset \
#              --lastname Admin \
#              --email admin@superset.com \
#              --password admin
