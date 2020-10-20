#!/bin/bash

clear
make clean
make
make strace
make diff
