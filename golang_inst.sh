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
# golang_inst.sh is used to easily install golang tools in linux box.
#
# @author Harrison Feng <feng.harrison@gmail.com>
# @file golang_inst.sh


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


# Error code
INVALID_ARGS=5


GO_VERSION=$1
DEFAULT_OS_ARCH=linux-amd64
GO_TOOLS_URL=https://storage.googleapis.com/golang/go${GO_VERSION}.${DEFAULT_OS_ARCH}.tar.gz


command_exists() {
    command -v "$@" > /dev/null 2>&1;
}


usage() {
    echo -e "${TXTRED}
    ===============================================
    usage:     `basename $0` GO_VERSION [OS_ARCH]
    example:   go_install 1.6.3
    ===============================================
    ${TXTRESET}\n"
}


check_args() {
    if [ -z "${GO_VERSION}" ]; then
        usage
        exit ${INVALID_ARGS}
    fi
}


install_go() {
    curl ${GO_TOOLS_URL} | tar -C /usr/local -zxvf -
    \cp  ${HOME}/.bashrc ${HOME}/.bashrc_backup_for_go_install
    echo "export PATH=\$PATH:/usr/local/go/bin" >> ${HOME}/.bashrc
    echo -e "${BTXTGREEN} --- Your Golang environment --- ${TXTRESET}\n"
    /usr/local/go/bin/go env
}


main() {
    # check arguments
    check_args
    if command_exists go; then
        while [ "${ANSWER}" != "Y" ] && [ "${ANSWER}" != "N" ]
        do
            echo -n -e "\n${TXTRED}
            Golang is existing in your system, are you sure still installing it?${TXTRESET}\n
            Y(${BTXTRED}Y${TXTRESET}es), N(${BTXTRED}N${TXTRESET}o):
            "
            read ANSWER
        done
        case "${ANSWER}" in
            "N")
                exit 0
                ;;
            "Y")
                install_go
                ;;
        esac
    else
        install_go
    fi
}

main


# ====== Shell script ending ======
