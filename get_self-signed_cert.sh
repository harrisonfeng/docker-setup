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
# @file get_self-signed_cert.sh


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

DOMAIN_NAME=$1
DOCKER_CERTS_DIR=/etc/docker/certs.d


usage() {
    if [ -z "$DOMAIN_NAME" ]; then
        echo -e "$TXTRED
    ##############################################

    Please give me the your server domain name
    Usage: $0  your_domain_name

    ##############################################
    $TXTRESET"
    exit $ERROR_CODE
    fi
}

get_self_signed_cert() {
    if [ ! -d $DOCKER_CERTS_DIR/$DOMAIN_NAME ]; then
        mkdir -p $DOCKER_CERTS_DIR/$DOMAIN_NAME
    fi
    echo -n | openssl s_client -connect $DOMAIN_NAME:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $DOCKER_CERTS_DIR/$DOMAIN_NAME/$DOMAIN_NAME.crt
}

usage
get_self_signed_cert

