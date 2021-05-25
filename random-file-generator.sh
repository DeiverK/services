#!/usr/bin/env bash

# Usage
# script.sh /path/to/create/files

path=$1

for i in {1..2048}
do
    name=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13)
    new_file="${path}/${name}.testing"
    touch ${new_file}
    echo ${i} >> ${new_file}
    echo "${name}" >> ${new_file}
done
