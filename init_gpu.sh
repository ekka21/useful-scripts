#!/bin/bash
set -ex

nvidia-docker run -d \
  -p 8081:8888 \
  -v /data:/home/jovyan/work \
  -e GRANT_SUDO=yes \
  -e JUPYTER_ENABLE_LAB=yes \
  -e HOME=/home/jovyan/work \
  -e NB_UID=1000 \
  -e NB_GID=1000 \
  --user root \
  --name gpu_test \
  --restart=always \
  gpu:test
  #gpu-jupyter:latest

docker cp $(which nvtop) gpu_test:$(which nvtop)

#nvidia-docker run --name="jupyterlab" -p 8888:8888 -d -e HOME=/tf -e JUPYTER_ENABLE_LAB=yes -e GRANT_SUDO=yes --user root -v /data:/tf tensorflow/tensorflow:1.15.5-gpu-py3-jupyter
docker run --gpus all -d -p 8081:8888 -v /data:/home/jovyan/work -e GRANT_SUDO=yes -e JUPYTER_ENABLE_LAB=yes -e NB_UID="$(id -u)" -e NB_GID="$(id -g)" --user root --restart always --name gpu-jupyter_1 gpu-jupyter

