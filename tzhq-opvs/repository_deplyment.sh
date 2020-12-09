#!/bin/bash

mkdir /data
cd /data/

cd /opt/
wget https://sonatype-download.global.ssl.fastly.net/repository/repositoryManager/3/nexus-3.20.1-01-unix.tar.gz
tar -xvf nexus-3.20.1-01-unix.tar.gz
mv nexus-3.20.1-01-unix nexus

