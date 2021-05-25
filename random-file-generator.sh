#!/usr/bin/env bash

path=$1



for i in {1..2048}
do
    name=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13)
    new_file="${path}/${name}.testing"
    touch ${new_file}
    for i2 in {1..2}
    do
        echo ${i} >> ${new_file}
        echo "${name}" >> ${new_file}
        echo $(tr -dc A-Za-z0-9 </dev/urandom | head -c 256) >> ${new_file}
    done
done
