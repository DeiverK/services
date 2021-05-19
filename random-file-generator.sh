#!/usr/bin/env bash

for i in {1..2048}
do
    name=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13)
    touch ${name}.testing
    echo ${i} >> ${name}.testing
    echo "${name}" >> ${name}.testing
done
