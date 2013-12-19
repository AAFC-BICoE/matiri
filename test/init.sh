#!/bin/bash

BATS_INSTALL='bats-install'

if [ ! -e $BATS_INSTALL ]; then
    rm -rf bats
    git clone https://github.com/sstephenson/bats.git &> /dev/null
    cd bats
    git checkout 2476770c84df6f296adc9e4228af9cf9463c4458 &> /dev/null
    mkdir ../bats-install
    ./install.sh ../bats-install &> null
    cd ..
    rm -rf bats
fi










