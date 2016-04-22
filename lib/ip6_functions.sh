#!/usr/bin/env bash
##########################################################################
# Copyright 2016 Vuid Pty Ltd 
# https://www.vuid.com
#
# This file is part of tredly-build.
#
# tredly-build is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# tredly-build is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with tredly-build.  If not, see <http://www.gnu.org/licenses/>.
##########################################################################

# params: startaddress, cidr
function ip6_find_available_address() {
    #local network="2001:470:26:307"
    local _network="fd76:6df6:8457:1553"
    local _array=( 1 2 3 4 5 6 7 8 9 0 a b c d e f )
    
    echo "${_network}:${_array[$RANDOM%16]}${_array[$RANDOM%16]}${_array[$RANDOM%16]}${_array[$RANDOM%16]}:${_array[$RANDOM%16]}${_array[$RANDOM%16]}${_array[$RANDOM%16]}${_array[$RANDOM%16]}:${_array[$RANDOM%16]}${_array[$RANDOM%16]}${_array[$RANDOM%16]}${_array[$RANDOM%16]}:${_array[$RANDOM%16]}${_array[$RANDOM%16]}${_array[$RANDOM%16]}${_array[$RANDOM%16]}"
}


function ip6_get_container_interface_ip() {
    local _uuid="${1}"
    local _iface="${2}"

    local _output=$( jexec trd-${_uuid} ifconfig ${interface} | awk 'sub(/inet6 /,""){print $1}' )

    local _retVal=$?
    echo "${_output}"
    return ${_retVal}
}