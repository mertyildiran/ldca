#!/bin/bash

clear
make clean
make dev
timeout 0.4 make strace
make diff
