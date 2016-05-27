#!/bin/bash

# Docker Setup
#
# Copyright (C) 2016 Harrison Feng <feng.harrison@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see [http://www.gnu.org/licenses/].
#
# Docker Setup is a project which enable docker environment easily in your
# linux box.
#
# @author Harrison Feng <feng.harrison@gmail.com>
# @file docker_setup.sh


# Color Definition
TXTRESET='\e[0m'
TXTRED='\e[0;31m'
TXTGREEN='\e[0;32m'
TXTBLUE='\e[0;34m'
TXTPURPLE='\e[0;35m'

BTXTRED='\e[1;31m'
BTXTGREEN='\e[1;32m'
BTXTBLUE='\e[1;34m'

ERROR_CODE=2 # Invalid parameters

VERSION=$1


command_exists() { command -v "$@" > /dev/null 2>&1; }

usage(){
    if [ -z "$VERSION" ]; then
        echo -e "$TXTRED
    ##############################################
    Please give me the docker version (e.g. 1.9.1)

    Usage: $0 1.9.1

    Here are versions available:
    1.7.0 1.7.1 
    1.8.0 1.8.1 1.8.2 1.8.3
    1.9.0 1.9.1 
    1.10.0 1.10.1 1.10.2 1.10.3
    1.11.0 1.11.1
    ##############################################
    $TXTRESET"
    exit $ERROR_CODE
    fi
}

prepare_repo() {
    if [ ! -f /etc/yum.repos.d/docker.repo ]; then
        \cp -f docker.repo /etc/yum.repos.d/
    fi
}

install_docker() {
    yum install -y docker-engine-$VERSION
    \cp -f ./nsdocker /usr/local/bin
}

usage
prepare_repo
install_docker

if command_exists docker; then
    service docker start
else
    echo "Docker doesn't exist, please check if it's installed correctly!"
fi
