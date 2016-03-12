Rep related to scripts for the 1000 genome portion of the tech. pilot

Ref data:
https://signpost.opensciencedatacloud.org/alias/ark:/31807/DC2-39d246e3-c991-4368-a707-b74c19f16ce0




# Install
apt-get update

sudo apt-get install git

mkdir -p ~/git
cd ~/git

# download repos
mkdir -p ~/git
cd ~/git
git clone https://github.com/DrOppenheimer/Kevin_python_scripts.git
git clone https://github.com/DrOppenheimer/Kevin_shell_scripts.git
git clone https://github.com/Shenglai/mutect2_pon_cwl.git
git clone https://github.com/DrOppenheimer/tp_1000g.git

# permanently add repos to path
cd ~/git/Kevin_shell_scripts
./add_dir_2_path.sh
. ~/.bashrc # "." or "source" depending on the environment
cd ~/git/mutect2-pon-cwl; add_dir_2_path.sh; . ~/.bashrc
cd ~/git/Kevin_python_scripts; add_dir_2_path.sh; . ~/.bashrc
cd ~/git/tp_1000g.git; add_dir_2_path.sh; . ~/.bashrc
cd ~

sudo apt-get install -y default-jre
sudo apt-get install -y default-jdk
sudo apt-get install -y uuid
sudo apt-get install -y python-pip
sudo pip install cwl-runner

sudo apt-get install -y npm
sudo ln -s /usr/bin/nodejs /usr/bin/node

# install docker
sudo apt-get install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

sudo rm /etc/apt/sources.list.d/docker.list
sudo echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get purge lxc-docker
sudo apt-cache policy docker-engine
sudo apt-get install docker.io
sudo service docker start

# download ref files
mkdir -p /mnt/mutect_ref_files/
cd /mnt/mutect_ref_files/
ARK_download.py -a 'https://signpost.opensciencedatacloud.org/alias/ark:/31807/DC2-39d246e3-c991-4368-a707-b74c19f16ce0' -d -p 'https://griffin'

tar -xzf 1000_genome_ref_files.3-7-16.tar.gz

# common docker commands



### commit local docker image changes to quay.io
# log into quay,io
sudo docker login quay.io

# then get the id
sudo docker ps -l
# commit it
sudo docker commit 353f433cdc43 quay.io/droppenheimer/predixcan
# push it
sudo docker push quay.io/droppenheimer/predixcan

# try local image with attaching the data
sudo docker run -t -i quay.io/droppenheimer/predixcan /bin/bash



# download and unzip reference data
