#!/bin/bash

# Simple script to download the reference data
# download and unzip in default location
mkdir -p /mnt/mutect_ref_files
cd /mnt/mutect_ref_files
ARK_download.gamma.py -a 'https://signpost.opensciencedatacloud.org/alias/ark:/31807/DC2-39d246e3-c991-4368-a707-b74c19f16ce0' -d -p 'https://griffin-objstore' -b
tar -xzvf 1000_genome_ref_files.3-7-16.tar.gz
cd ~
