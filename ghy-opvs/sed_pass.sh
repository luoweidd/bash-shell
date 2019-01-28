#!/bin/sh

files=`find /opt/new_project/ -name mongo_single.properties`

for file in ${files[@]}
do
    sed -i "s/9aP)(cd5+/WERteol367765/g" $file
done
