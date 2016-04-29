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

# checks where an ip address is RFC 1918 private or not
# https://en.wikipedia.org/wiki/Private_network#Private_IPv4_address_spaces
function is_private_ip4() {
    local _checkIP="${1}"

    # explode the ip into its elements
    IFS=. read -r i1 i2 i3 i4 <<< "${_checkIP}"

    # check for private ranges
    if [[ i1 -eq 10 ]]; then
        return ${E_SUCCESS}
    elif [[ i1 -eq 172 ]]; then
        if [[ i2 -ge 16 ]] && [[ i2 -le 31 ]]; then
            return ${E_SUCCESS}
        fi
    elif [[ i1 -eq 192 ]] && [[ i2 -eq 168 ]]; then
        return ${E_SUCCESS}
    fi
    return ${E_ERROR}
}

# randomly generates a port number and checks to see if it is in use
# there is no reason why this cant simply start at minPort and increment
# params: protocol, ipaddress
function find_available_port() {
    local protocol="${1}"
    local ipAddr="${2}"
    local _minPort="${3}"
    local _maxPort="${4}"
    
    local newPort=""
    
    while [[ -z "$newPort" ]]; do
        # get a random number between our given ranges
        local randomPort=$( jot -r 1 ${_minPort} ${_maxPort} )
        
        # check to see if its in use
        local output=$( sockstat -4 | grep -F " ${ipAddr}:${randomPort} "  | grep -F " ${protocol}4 " | wc -l )
        
        # its not in use so assign this port
        if [[ "$output" -eq 0 ]]; then
            newPort="${randomPort}"
        fi
    done
    
    if [[ -n "${newPort}" ]]; then
        echo "${newPort}"
        return ${E_SUCCESS}
    fi
    
    echo ''
    return ${E_FATAL}
}

# finds an available ip address within the given network
# params: startaddress, cidr
function find_available_ip_address() {
    local network="${1}"
    local cidr="${2}"
    
    local newIP=""
    local nextaddr=""
    
    # get the next ip, check to see if its in use
    while [[ -z "$newIP" ]]; do
        nextaddr=$( get_ip4_random_address "${network}" "${cidr}" )
        
        if [[ $? -eq ${E_FATAL} ]]; then
            exit_with_error "IP address pool exhausted!"
        fi

        # check if its in use
        #output=$( ifconfig | grep -F " ${nextaddr} " | wc -l )
        local output=$( zfs get -H -o property,value -r ${ZFS_PROP_ROOT}:ip4_addr ${ZFS_TREDLY_PARTITIONS_DATASET} | grep -F "|${nextaddr}/" | wc -l )
        
        if [[ "${output}" -eq 0 ]]; then
            newIP="${nextaddr}"
        fi

    done
    
    echo "$newIP"
    return ${E_SUCCESS}
}

## Uses ifconfig and to obtain the ip address(es) for a given network interface
##
## Arguments:
##     1. String. Network interface name
##
## Usage:
##     
##
## Return:
##     array
function get_interface_ip4() {
    local interface="${1}"

    local output=$( ifconfig ${interface} | awk 'sub(/inet /,""){print $1}' )

    local retVal=$?
    echo "${output}"
    return ${retVal}
}

# gets the ip address of a container's interface
function get_container_interface_ip4() {
    local _uuid="${1}"
    local _iface="${2}"

    local _output=$( jexec trd-${_uuid} ifconfig ${interface} | awk 'sub(/inet /,""){print $1}' )

    local _retVal=$?
    echo "${_output}"
    return ${_retVal}
}

## Uses ifconfig and grep to look for the network interface
## specified in the first argment.
##
## Arguments:
##     1. String. Network interface name
##
## Usage:
##     if network_interface_exists "lo1"; then echo good; else echo bad; fi
##
## Return:
##     bool
function network_interface_exists() {
    local result=0

    if [[ -z $(ifconfig | grep "^${1}:") ]]; then
        result=1
    fi

    return $result
}

# given an ip4 address, return the next in the sequence
function get_ip4_next_address() {
    local ip4="${1}"
    # convert the cidr into a netmask
    local netmask=$( cidr2netmask "${2}" )
    local broadcast=$( get_ip4_broadcast_address "${ip4}" "${2}" )

    local m1 m2 m3 m4
    local o1 o2 o3 o4

    IFS=. read -r o1 o2 o3 o4 <<< "${ip4}"
    IFS=. read -r m1 m2 m3 m4 <<< "${netmask}"

    # increment the last octet
    o4=$(( $o4 + 1  ))

    # attempt to get the next ip address
    if [[ "$o4" -gt 255 ]]; then
        o4=0
        o3=$(( $o3 + 1 ))

        if [[ "$o3" -gt 255 ]]; then
            o3=0
            o2=$(( $o2 + 1 ))

            if [[ "$o2" -gt 255 ]]; then
                o2=0
                o1=$(( $o1 + 1 ))
                
                if [[ "$o1" -gt 255 ]]; then
                    echo ""
                    return ${E_FATAL}
                fi
            fi
        fi
    fi

    newIP=$(printf "%d.%d.%d.%d" "${o1}" "${o2}" "${o3}" "${o4}")

    # make sure we're not going to output the broadcast address
    if [[ "${newIP}" != "${broadcast}" ]]; then
        echo "$newIP"
        return ${E_SUCCESS}
    fi

    echo ""
    return ${E_FATAL}
}

# given an ip4, finds the last usable ip4 address in the network
function get_last_usable_ip4_in_network() {
    local ip4="${1}"

    # convert the cidr into a netmask
    local broadcast=$( get_ip4_broadcast_address "${ip4}" "${2}" )

    local b1 b2 b3 b4

    IFS=. read -r b1 b2 b3 b4 <<< "${broadcast}"

    # decrement the last octet
    b4=$(( b4 - 1 ))

    printf "%d.%d.%d.%d" "${b1}" "${b2}" "${b3}" "${b4}"
    return ${E_SUCCESS}
}

# Returns a random address from a given network and cidr
function get_ip4_random_address() {
    local network="${1}"
    # convert the cidr into a netmask
    local cidr="${2}"
    local netmask=$( cidr2netmask "${cidr}" )
    local broadcast=$( get_ip4_broadcast_address "${network}" "${2}" )

    if [[ ${cidr} -eq 32 ]]; then
        echo "${network}"
        return ${E_SUCCESS}
    fi

    local n1 n2 n3 n4
    local b1 b2 b3 b4
    local r1 r2 r3 r4

    IFS=. read -r n1 n2 n3 n4 <<< "${network}"
    IFS=. read -r b1 b2 b3 b4 <<< "${broadcast}"

    # increment/decrement the last octet as this is the network or broadcast addres
    if [[ ${n4} -lt 255 ]]; then
        n4=$(( n4 + 1 ))
    fi

    if [[ ${b4} -gt 0 ]]; then
        b4=$(( b4 - 1 ))
    fi

    #randomise each octet between network and broadcast addresses 
    local r1=$( jot -r 1 ${n1} ${b1} )
    local r2=$( jot -r 1 ${n2} ${b2} )
    local r3=$( jot -r 1 ${n3} ${b3} )
    local r4=$( jot -r 1 ${n4} ${b4} )

    newIP=$(printf "%d.%d.%d.%d" "${r1}" "${r2}" "${r3}" "${r4}")

    # make sure we're not going to output the broadcast address or network address
    if [[ "${newIP}" != "${broadcast}" ]] && [[ "${newIP}" != "${network}" ]]; then
        echo "$newIP"
        return ${E_SUCCESS}
    fi

    echo ""
    return ${E_FATAL}
}

# Converts a netmask to a cidr
function netmask2cidr() {
   # Assumes there's no "255." after a non-255 byte in the mask
   local x=${1##*255.}
   set -- 0^^^128^192^224^240^248^252^254^ $(( (${#1} - ${#x})*2 )) ${x%%.*}
   x=${1%%$3*}
   echo $(( $2 + (${#x}/4) ))
   return ${E_SUCCESS}
}

# takes a cidr (in the form of 16,24,32 etc) and outputs its equivalent netmask
function cidr2netmask() {
    local i mask=""
    local full_octets=$(($1/8))
    local partial_octet=$(($1%8))

    for ((i=0;i<4;i+=1)); do
        if [ $i -lt $full_octets ]; then
            mask+=255
        elif [ $i -eq $full_octets ]; then
            mask+=$((256 - 2**(8-$partial_octet)))
        else
            mask+=0
        fi  
        test $i -lt 3 && mask+=.
    done

    echo $mask
    return $E_SUCCESS
}

# takes 2 args - 1st is the ip4_addr. ie <iface>|<ip4addr>/<cidr>
# 2nd is a string. eg "ip4, cidr, or interface". defaults to ip4
function extractFromIP4Addr() {
    local _ip4_addr="${1}"
    local _toExtract="${2}"
    # split it
    [[ ${_ip4_addr} =~ ^([^|]+)\|(.+)/(.+)$ ]]
    
    case "${_toExtract}" in
        interface)
            echo "${BASH_REMATCH[1]}"
            ;;
        cidr|netmask)
            echo "${BASH_REMATCH[3]}"
            ;;
        *)  # aka ip4
            echo "${BASH_REMATCH[2]}"
            ;;
    esac
    return $E_SUCCESS
}

# takes an ip address, and checks if it is valid or not
function is_valid_ip4() {
    # extract the ip4 address in case we were passed a netmask or cidr
    local _ip4=$( lcut "${1}" '/' )

    # make sure the string contains 3 dots
    local numDots=$(grep -o -F '.' <<< "${_ip4}" | wc -l)
    if [[ ${numDots} -ne 3 ]]; then
        return $E_ERROR
    fi

    # explode the ip into its elements and loop over them
    local IFS='.'
    for value in ${_ip4}
    do
        # if this value is < 0 or > 255 then its bogus
        if [[ "$value" -lt "0" || "$value" -gt "255" || ! "$value" =~ ^[0-9]{1,3}$ ]]; then
            return $E_ERROR
        fi
    done

    return $E_SUCCESS
}

# takes an ip address, and checks if it is valid or not
function is_valid_cidr() {
    if ! is_int "${1}"; then
        return $E_ERROR
    fi
   
    if [[ "${1}" -lt "0" ]] || [[ "${1}" -gt "32" ]]; then
        return $E_ERROR
    fi

    return $E_SUCCESS
}

# Given an ip address and netmask, calculate the network address
# eg: ip4     = 192.168.0.240
#     netmask = 255.255.255.0
# networkaddr = 192.168.0.0
function get_ip4_network_address() {
    local ip4="${1}"
    # convert the cidr into a netmask
    local netmask=$( cidr2netmask "${2}" )

    local i1 i2 i3 i4
    local m1 m2 m3 m4

    IFS=. read -r i1 i2 i3 i4 <<< "${ip4}"
    IFS=. read -r m1 m2 m3 m4 <<< "${netmask}"

    printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))"
}

# Given an ip address and netmask, calculate the broadcast address
# eg: ip4       = 192.168.0.240
#     netmask   = 255.255.255.0
# broadcastaddr = 192.168.0.255
function get_ip4_broadcast_address() {
    local ip4="${1}"
    # convert the cidr into a netmask
    local netmask=$( cidr2netmask "${2}" )

    local i1 i2 i3 i4
    local m1 m2 m3 m4

    IFS=. read -r i1 i2 i3 i4 <<< "${ip4}"
    IFS=. read -r m1 m2 m3 m4 <<< "${netmask}"

    # wildcard it
    m1=$((255 - m1))
    m2=$((255 - m2))
    m3=$((255 - m3))
    m4=$((255 - m4))

    printf "%d.%d.%d.%d\n" "$((i1 | m1))" "$((i2 | m2))" "$((i3 | m3))" "$((i4 | m4))"
}

# takes an ip4 address and a network address (including cidr) and checks to see if that ip4 address falls within the given network
function ip4_is_network_member() {
    local _ip4="${1}"

    # split out the network and cidr
    local _network _cidr
    IFS=/ read -r _network _cidr <<< "${2}"

    local _broadcast=$( get_ip4_broadcast_address "${_network}" "${_cidr}" )

    # separate the ip addresses into their octets
    IFS=. read -r i1 i2 i3 i4 <<< "${_ip4}"
    IFS=. read -r n1 n2 n3 n4 <<< "${_network}"
    IFS=. read -r b1 b2 b3 b4 <<< "${_broadcast}"

    # check each octet
    if [[ i1 -ge n1 ]] && [[ i1 -le b1 ]]; then
        # 2nd octet
        if [[ i2 -ge n2 ]] && [[ i2 -le b2 ]]; then
            # 3rd octet
            if [[ i3 -ge n3 ]] && [[ i3 -le b3 ]]; then
                # 4th octet
                if [[ i4 -ge n4 ]] && [[ i4 -le b4 ]]; then
                    return $E_SUCCESS
                fi
            fi
        fi
    fi

    return $E_ERROR
}
# generates a random mac address
function generate_mac_address() {
    local RANGE=255

    #generate random numbers
    local number=$RANDOM
    local numbera=$RANDOM
    local numberb=$RANDOM
    
    #ensure they are less than ceiling
    let "number %= $RANGE"
    let "numbera %= $RANGE"
    let "numberb %= $RANGE"

    # set mac stem
    local octets="02:33:11"

    #use a command line tool to change int to hex(bc is pretty standard)
    #they're not really octets.  just sections.
    local octeta=`echo "obase=16;$number" | bc`
    local octetb=`echo "obase=16;$numbera" | bc`
    local octetc=`echo "obase=16;$numberb" | bc`

    echo "${octets}:${octeta}:${octetb}:${octetc}"
}