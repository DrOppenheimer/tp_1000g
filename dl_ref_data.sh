#!/bin/bash
# Simple script to install ref data for Mutect 

#REF_FILE="/mnt/mutect_ref_files/Homo_sapiens_assembly38.fa" # this way for VMs
# This way for docker
REF_FILE="~/mutect_ref_files/Homo_sapiens_assembly38.fa"

# check for ref data - download if it isn't there
if [ ! -e $REF_FILE ]; then
    #sudo chown ubuntu:ubuntu /mnt                           # this way for VMs
    #mkdir -p /mnt/mutect_ref_files                          # this way for VMs
    #cd /mnt/mutect_ref_files                                # this way for VMs
    # This way for docker
    mkdir -p ~/mutect_ref_files
    cd ~/mutect_ref_files
    ARK_download.gamma.py -a 'https://signpost.opensciencedatacloud.org/alias/ark:/31807/DC2-39d246e3-c991-4368-a707-b74c19f16ce0' -d -p 'https://griffin-objstore' -b
    tar -xzvf 1000_genome_ref_files.3-7-16.tar.gz
    echo "Done installing reference data"
else
    echo "Ref data is already installed"
fi
