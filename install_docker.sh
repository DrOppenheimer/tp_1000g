#!/bin/bash

# install docker 
sudo -E apt-get install -y docker.io
# add proxy to docker
sudo bash
echo "export http_proxy=http://cloud-proxy:3128" >> /etc/default/docker
echo "export https_proxy=http://cloud-proxy:3128" >> /etc/default/docker 
exit
# and pull the images from quay.io
DOCKERDIR="/mnt/docker_mages"
sudo service docker restart
sudo docker login quay.io
mkdir -p $DOCKERDIR
sudo docker pull -g $DOCKERDIR quay.io/ncigdc/mutect2-pon-tool
sudo docker pull -g $DOCKERDIR quay.io/ncigdc/cramtools
sudo docker pull -g $DOCKERDIR quay.io/shenglai/picard-tool
sudo docker pull -g $DOCKERDIR quay.io/ncigdc/mutect2-pon-tool
sudo docker pull -g $DOCKERDIR quay.io/jeremiahsavage/merge_sqlite
sudo docker pull -g $DOCKERDIR commonworkflowlanguage/nodejs-engine
# will be placed in /var/lib/docker

