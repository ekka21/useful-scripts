#!/bin/bash
set -ex

#format
#sudo mkfs -t xfs /dev/nvme1n1

sudo mkdir -p /data
sudo mount /dev/nvme1n1 /data

