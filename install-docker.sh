#!/bin/bash
set -ex

sudo apt update -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update -y
sudo apt install -y docker-ce
sudo usermod -aG docker ubuntu
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose


docker run --name="jupyterlab" --memory="30g" --memory-swap="1G" --cpus="15.5" -p 8888:8888 -d -e JUPYTER_ENABLE_LAB=yes -e GRANT_SUDO=yes --user root -v /data:/home/jovyan/work jupyter/base-notebook:python-3.7.6


