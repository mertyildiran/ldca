#!/bin/bash

OUTS_DIR=outs

for file in $(find ${OUTS_DIR}/* -not -name "*.xxd");
do
    xxd "$file" > "${file}.xxd"
done

for file in ${OUTS_DIR}/*.xxd
do
    git diff --no-index --color ${OUTS_DIR}/0000000000000000000000000000000000000000000000000.xxd "$file" | cat
done
