#!/bin/sh

starpath=`find /opt/new_project/ -name start.sh`

for starfilepath in ${starpath[@]} 
do
    echo "copy $starfilepath"

    zip star_sh.zip $starfilepath
done
