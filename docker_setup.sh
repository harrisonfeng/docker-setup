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


# ====== Shell script starting ======


# Color Definition
TXTRESET='\e[0m'
TXTRED='\e[0;31m'
TXTGREEN='\e[0;32m'
TXTBLUE='\e[0;34m'
TXTPURPLE='\e[0;35m'

BTXTRED='\e[1;31m'
BTXTGREEN='\e[1;32m'
BTXTBLUE='\e[1;34m'


DOCKER_VERSION=$1
ERROR_CODE=2       # Invalid parameters
UNSUPPORTED_OS=4   # Unsupported OS


command_exists() {
    command -v "$@" > /dev/null 2>&1;
}


usage() {
    if [ -z "$DOCKER_VERSION" ]; then
        echo -e "$TXTRED
    ==============================================
    Please give me the docker version (e.g. 1.9.1)

    Usage:    ./`basename $0` DOCKER_VERSION
    Example:  ./`basename $0` 1.11.2

    Here are versions available:
    1.7.0 1.7.1 
    1.8.0 1.8.1 1.8.2 1.8.3
    1.9.0 1.9.1 
    1.10.0 1.10.1 1.10.2 1.10.3
    1.11.0 1.11.1 1.11.2
    1.12.0 1.12.1 1.12.2 1.12.3
    ==============================================
    $TXTRESET"
    exit $ERROR_CODE
    fi
}


setup_repo_ubuntu() {
    CODENAME=$(lsb_release -c | tr -d [:blank:] | cut -d: -f2)

    sudo apt-get install -y apt-transport-https ca-certificates

    sudo apt-key adv --keyserver \
    hkp://p80.pool.sks-keyservers.net:80 \
    --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

    sudo touch /etc/apt/sources.list.d/docker.list
    echo "deb https://apt.dockerproject.org/repo ubuntu-$CODENAME main" | sudo tee -a \
    /etc/apt/sources.list.d/docker.list

    sudo apt-get update
    sudo groupadd docker
    sudo usermod -aG docker $USER
}


setup_repo_centos() {
    if [ ! -f /etc/yum.repos.d/docker.repo ]; then
        \cp -f docker.repo /etc/yum.repos.d/
    fi
}


install_docker() {
    if command_exists yum; then
        setup_repo_centos
        yum install -y docker-engine-$DOCKER_VERSION
    elif command_exists apt-get; then
        setup_repo_ubuntu
        sudo apt-get -y install docker-engine=${DOCKER_VERSION}\*
    else
        echo "Your OS system is not supported."
        exit $UNSUPPORTED_OS
    fi
}


install_nsdocker() {
    sudo \cp -f ./nsdocker /usr/local/bin
}


main() {
    usage
    install_docker
    install_nsdocker
    if command_exists docker; then
        sudo systemctl restart docker
    else
        echo "${BTXTRED}Docker doesn't exist, please check if it's installed correctly!${TXTRESET}"
    fi
}


main


# ====== Shell script ending ======
