#!/bin/bash

# set user to sudo
# sudo usermod -aG docker ubuntu

# make sure /mnt permissions are set
sudo chown ubuntu:ubuntu /mnt

# add proxy to ~/.bashrc
sudo echo "export http_proxy=\"http://cloud-proxy:3128\"" >> ~/.bashrc
sudo echo "export https_proxy=\"http://cloud-proxy:3128\"" >> ~/.bashrc
source ~/.bashrc

# udate and upgrade
sudo -E apt-get update
sudo -E apt-get upgrade -y

# configure a cfg (~/.pdc.s3.cfg) for PDC Object store

# touch ~/.pdc.s3.cfg
# echo "access_key=HKEYKEYKEYF" >> ~/.pdc.s3.cfg
# echo "secret_key=THkKEYKEYKEYk" >> ~/.pdc.s3.cfg
# echo "host_bucket=rados-bionimbus-pdc.opensciencedatacloud.org" >> ~/.pdc.s3.cfg
# echo "host_base=rados-bionimbus-pdc.opensciencedatacloud.org" >> ~/.pdc.s3.cfg
# remember to reference these cfg files with -c for s3cmd
# configure a cfg (~/.grif.s3.cfg) for Griffin
# touch ~/.grif.s3.cfg
# echo "access_key=DKEYKEYKEY9" >> ~/.grif.s3.cfg 
# echo "secret_key=WmKEYKEYKEYKEYKEYT0" >> ~/.grif.s3.cfg
# echo "host_bucket=griffin-objstore.opensciencedatacloud.org" >> ~/.grif.s3.cfg
# echo "host_base=griffin-objstore.opensciencedatacloud.org" >> ~/.grif.s3.cfg


# make sure that /etc/hosts contains (second line from /etc/hostname)
# 127.0.0.1    localhost.localdomain localhost
# 127.0.1.1    my-machine
sudo bash
my_machine=`head -n 2 /etc/hostname | tail -n 1`
sudo echo 127.0.1.1" $my_machine" >> /etc/hosts
exit

# install packages
sudo -E apt-get install -y s3cmd git default-jre default-jdk uuid npm python-setuptools
sudo -E apt-get update 
sudo -E easy_install -U setuptools
sudo -E apt-get install -y python-pip
sudo -E pip install cwl-runner
sudo ln -s /usr/bin/nodejs /usr/bin/node

# Install git repos
mkdir -p ~/git
cd ~/git
sudo -E git clone https://github.com/DrOppenheimer/Kevin_python_scripts.git
sudo -E git clone https://github.com/DrOppenheimer/Kevin_shell_scripts.git
sudo -E git clone https://github.com/DrOppenheimer/tp_1000g.git
sudo -E git clone -b develop https://github.com/NCI-GDC/mutect2-pon-cwl.git # you will need access to this repo
sudo -E git clone -b develop https://github.com/NCI-GDC/cramtools.git # you will need access to this repo
# permanently add repos to path
cd ~/git/Kevin_shell_scripts
./add_dir_2_path.sh
. ~/.bashrc # "." or "source" depending on the environment
cd ~/git/Kevin_python_scripts; add_dir_2_path.sh; . ~/.bashrc
cd ~/git/tp_1000g; add_dir_2_path.sh; . ~/.bashrc
cd ~/git/mutect2-pon-cwl; add_dir_2_path.sh; . ~/.bashrc
cd ~/git/cramtools; add_dir_2_path.sh; . ~/.bashrc
cd ~

# install docker 
sudo -E apt-get install -y docker.io
# add proxy to docker
sudo bash
echo "export http_proxy=http://cloud-proxy:3128" >> /etc/default/docker
echo "export https_proxy=http://cloud-proxy:3128" >> /etc/default/docker 
exit
# and pull the images from quay.io

sudo service docker restart
sudo bash 
DOCKERDIR="/mnt/docker_mages"
docker login quay.io
mkdir -p $DOCKERDIR
exit
#################### save for run
sudo -E docker pull -g $DOCKERDIR quay.io/ncigdc/mutect2-pon-tool
sudo -E docker pull -g $DOCKERDIR quay.io/ncigdc/cramtools
sudo -E docker pull -g $DOCKERDIR quay.io/shenglai/picard-tool
sudo -E docker pull -g $DOCKERDIR quay.io/ncigdc/mutect2-pon-tool
sudo -E docker pull -g $DOCKERDIR quay.io/jeremiahsavage/merge_sqlite
sudo -E docker pull -g $DOCKERDIR commonworkflowlanguage/nodejs-engine
# would be placed in /var/lib/docker by default
####################

# install parcel and configure to run as daemon
# install
cd ~/git
sudo -E git clone https://github.com/LabAdvComp/parcel.git
cd ~/git/parcel
sudo -E ./install # run twice?? (get an error sometimes about c library not installed, speedup not enabled if you run just once)
# run client (tcp2udt) as daemon (with supervisor d)
sudo -E apt-get install -y supervisor
sudo bash
echo "[program:parcel]" >> /etc/supervisor/conf.d/parcel.conf
echo "command=/usr/local/bin/parcel-tcp2udt -v 172.16.128.7:9000" >> /etc/supervisor/conf.d/parcel.conf
echo "user=parcel" >> /etc/supervisor/conf.d/parcel.conf
echo "autostart=true" >> /etc/supervisor/conf.d/parcel.conf
echo "autorestart=true" >> /etc/supervisor/conf.d/parcel.conf
echo "stderr_logfile=/var/log/parcel/supervisord_parcel_stderr.log" >> /etc/supervisor/conf.d/parcel.conf
echo "stdout_logfile=/var/log/parcel/supervisord_parcel_stdout.log" >> /etc/supervisor/conf.d/parcel.conf
exit
# create parcel user
sudo adduser --system parcel
# mkdir for parcel logs
sudo mkdir -p /var/log/parcel/
# start supervisor d
# Be sure to kill parcel if it is running already
sudo supervisord -c /etc/supervisor/supervisord.conf

sudo reboot
