#!/bin/bash

for file in $(find outs/* -not -name "*.xxd");
do
    xxd "$file" > "${file}.xxd"
done

for file in outs/*.xxd
do
    git diff --no-index --color 0000000000000000000000000000000000000000000000000.xxd "$file" | cat
done
