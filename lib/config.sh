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

# associative arrays
declare -A _CONF_COMMON
declare -A _CONF_TREDLYFILE

# standard arrays for multiple line entries in tredlyfile
declare -a _CONF_COMMON_DNS
declare -a _CONF_TREDLYFILE_TCPIN
declare -a _CONF_TREDLYFILE_TCPOUT
declare -a _CONF_TREDLYFILE_UDPIN
declare -a _CONF_TREDLYFILE_UDPOUT
declare -a _CONF_TREDLYFILE_URL
declare -a _CONF_TREDLYFILE_URLCERT
declare -a _CONF_TREDLYFILE_URLWEBSOCKET
declare -a _CONF_TREDLYFILE_URLMAXFILESIZE
declare -a _CONF_TREDLYFILE_TECHOPTIONS
declare -a _CONF_TREDLYFILE_STARTUP
declare -a _CONF_TREDLYFILE_SHUTDOWN
declare -a _CONF_TREDLYFILE_IP4WHITELIST
declare -a _CONF_TREDLYFILE_CUSTOMDNS

# Validates a common config file, for example tredly-host.conf
function common_conf_validate() {

    if [[ -z "${1}" ]]; then
        exit_with_error "common_conf_validate() cannot be called without passing at least 1 required field."
    fi

    ## Use 'required' from the common config to construct the required array
    local -a required
    IFS=',' read -a required <<< "${1}"

    ## Check for required fields
    for p in "${required[@]}"
    do
        # handle specific entries
        case "${p}" in
            dns)
                if [[ ${#_CONF_COMMON_DNS[@]} -eq 0 ]]; then
                    exit_with_error "'${p}' is missing or empty and is required. Check config"
            fi
            ;;
            *)
                if [ -z "${_CONF_COMMON[${p}]}" ]; then
                    exit_with_error "'${p}' is missing or empty and is required. Check config"
                fi
            ;;
        esac
    done

    return $E_SUCCESS
}

## Reads conf/{context}.conf, parsing it and storing each key/value pair
## in `_CONF_COMMON`. Path is built using _TREDLY_DIR, which is the directory
## that tredly script is running from.
## Arguments:
##      1. String. context. This must match the name of a config file (*.conf)
##
## Return:
##     - exits with error message if conf/{context}.conf does not exist
##
function common_conf_parse() {

    if [[ -z "${1}" ]]; then
        exit_with_error "common_conf_parse() cannot be called without providing a command as context"
    fi

    local context="${1}"

    if [ ! -e "${_TREDLY_DIR_CONF}/${context}.conf" ]; then
        e_verbose "No configuration found for \`${context}\`. Skipping."
        return $E_SUCCESS
    fi
    
    # empty our arrays
    _CONF_COMMON_DNS=()

    ## Read the data in
    local regexp="^[^#\;]*="

    while read line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^[^#\;]*= ]]; then
            key="${line%%=*}"
            value="${line#*=}"
            # strip anything after a comment
            value=$( lcut "${value}" '#' )
            
            # strip any whitespace
            local strippedValue=$(strip_whitespace "${value}")
            
            # handle some lines specifically
            case "${key}" in
                lifNetwork)
                    # split it up
                    [[ ${value#*=} =~ ^(.+)/(.+)$ ]]

                    # assign the values
                    _CONF_COMMON[lifNetwork]=${BASH_REMATCH[1]}
                    _CONF_COMMON[lifCIDR]=${BASH_REMATCH[2]}
                    ;;
                dns)
                    _CONF_COMMON_DNS+=("${value}")
                    ;;
                *)
                    _CONF_COMMON[${key}]="${value}"
                    ;;
            esac
        fi
    done < "${_TREDLY_DIR_CONF}/${context}.conf"

    return $E_SUCCESS
}

## Reads TredlyFile in directory provided, parsing it and storing each key/value pair
## in `_CONF_TREDLYFILE`. Also checks that at least one of tcpInPorts
## and udpInPorts is set. Lastly, iterates over list of 'fileFolderMapping' and makes sure
## the src folder exists.
##
## Arguments:
##      1. String. Directory containging Tredlyfile. If this is an empty string, assume CWD
##      2. Boolean. Optional. Skip validation
##
## Return:
##     - exits with error message if Tredlyfile does not exist
##     - exits with error message if any of the required fields are not present
##
function tredlyfile_parse() {

    local tredlyFile key value strippedValue

    tredlyFile="${1}"

    if [ ! -f "${tredlyFile}" ]; then
        # error if the file doesnt exist, exiting the function gracefully
        return $E_ERROR
    fi

    # empty our arrays
    _CONF_TREDLYFILE_TCPIN=()
    _CONF_TREDLYFILE_TCPOUT=()
    _CONF_TREDLYFILE_UDPIN=()
    _CONF_TREDLYFILE_UDPOUT=()
    _CONF_TREDLYFILE_URL=()
    _CONF_TREDLYFILE_URLCERT=()
    _CONF_TREDLYFILE_URLWEBSOCKET=()
    _CONF_TREDLYFILE_URLMAXFILESIZE=()
    _CONF_TREDLYFILE_TECHOPTIONS=()
    _CONF_TREDLYFILE_STARTUP=()
    _CONF_TREDLYFILE_SHUTDOWN=()
    _CONF_TREDLYFILE_IP4WHITELIST=()
    _CONF_TREDLYFILE_CUSTOMDNS=()

    ## Read the data in
    while read line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^[^#\;]*= ]]; then
            
            key="${line%%=*}"
            value="${line#*=}"
            # strip anything after a comment
            lvalue=$( lcut "${value}" '#' )
            rvalue=$( rcut "${value}" '#' )
            
            # check if the hash was escaped or not, and if so then stick it back together
            if [[ ${lvalue} =~ \\$ ]]; then
                value="${lvalue}#${rvalue}"
            else
                value="${lvalue}"
            fi

            # strip any whitespace
            local strippedValue=$(strip_whitespace "${value}")

            # do different things based off certain commands
            case "${key}" in
                url)
                    # add it to the array if it actually contained data
                    if [[ -n "${strippedValue}" ]]; then
                        _CONF_TREDLYFILE_URL+=("${value}")
                    fi
                    ;;
                urlCert)
                    # add it to the array
                    _CONF_TREDLYFILE_URLCERT+=("${value}")
                    ;;
                urlWebsocket)
                    # add it to the array
                    _CONF_TREDLYFILE_URLWEBSOCKET+=("${value}")
                    ;;
                urlMaxFileSize)
                    # validate it
                    if [[ -n "${value}" ]]; then
                        unit="${value: -1}"
                        unitValue="${value%?}"
                        
                        if [[ "${unit}" == "g" ]] || [[ "${unit}" == "G" ]]; then
                            # convert it to megabytes
                            unitValue=$(( ${unitValue} * 1024 ))
                            unit="m"
                        fi
                        # allow a max of 2gb and default of 1mb
                        if [[ "${unit}" == "m" ]] && [[ "${unitValue}" -gt "2048" ]]; then
                            _CONF_TREDLYFILE_URLMAXFILESIZE+=("2048m")
                        elif [[ "${unit}" == "m" ]] && [[ "${unitValue}" -le "2048" ]]; then
                            _CONF_TREDLYFILE_URLMAXFILESIZE+=("${unitValue}${unit}")
                        else
                            # default to 1mb
                            _CONF_TREDLYFILE_URLMAXFILESIZE+=("1m")
                        fi
                    fi
                    ;;
                tcpInPort)
                    # add it to the array if it actually contained data
                    if [[ -n "${strippedValue}" ]]; then
                        _CONF_TREDLYFILE_TCPIN+=("${value}")
                    fi
                    ;;
                udpInPort)
                    # add it to the array if it actually contained data
                    if [[ -n "${strippedValue}" ]]; then
                        _CONF_TREDLYFILE_UDPIN+=("${value}")
                    fi
                    ;;
                tcpOutPort)
                    # add it to the array if it actually contained data
                    if [[ -n "${strippedValue}" ]]; then
                        _CONF_TREDLYFILE_TCPOUT+=("${value}")
                    fi
                    ;;
                udpOutPort)
                    # add it to the array if it actually contained data
                    if [[ -n "${strippedValue}" ]]; then
                        _CONF_TREDLYFILE_UDPOUT+=("${value}")
                    fi
                    ;;
                technicalOptions)
                    # add it to the array if it actually contained data
                    if [[ -n "${strippedValue}" ]]; then
                        # strip out the technical options key to check that it is valid
                        techOptionsKey="${strippedValue%%=*}"
                        # validate it
                        if array_contains_substring VALID_TECHNICAL_OPTIONS[@] "^${techOptionsKey}$"; then
                            _CONF_TREDLYFILE_TECHOPTIONS+=("${value}")
                        fi
                    fi
                    ;;
                # startup commands
                onStart)
                    # add the entire line to the array to be interpreted later
                    if [[ -n "${strippedValue}" ]]; then
                        _CONF_TREDLYFILE_STARTUP+=("${key}=${value}")
                    fi
                    ;;
                installPackage|fileFolderMapping)
                    # add the entire line to the array to be interpreted later
                    if [[ -n "${strippedValue}" ]]; then
                        _CONF_TREDLYFILE_STARTUP+=("${key}=${value}")
                    fi
                    ;;
                partitionFolder)
                    if [[ -n "${strippedValue}" ]]; then
                        _CONF_TREDLYFILE_STARTUP+=("${key}=${value}")
                    fi
                    ;;
                persistentMountPoint)
                    if [[ -n "${strippedValue}" ]]; then
                        _CONF_TREDLYFILE_STARTUP+=("${key}=${value}")
                        # add it to the standard tredlyfile array too as we need it there
                        _CONF_TREDLYFILE[${key}]="${value}"
                    fi
                    ;;
                # shutdown commands
                onStop)
                    # add the entire line to the array to be interpreted later
                    if [[ -n "${strippedValue}" ]]; then
                        _CONF_TREDLYFILE_SHUTDOWN+=("${key}=${value}")
                    fi
                    ;;
                # whitelisted ip addresses for this container
                ipv4Whitelist)
                    if [[ -n "${strippedValue}" ]]; then
                        _CONF_TREDLYFILE_IP4WHITELIST+=("${strippedValue}")
                    fi
                    ;;
                # custom DNS for this container
                customDNS)
                    if [[ -n "${strippedValue}" ]]; then
                        _CONF_TREDLYFILE_CUSTOMDNS+=("${value}")
                    fi
                    ;;
                *)
                    _CONF_TREDLYFILE[${key}]="${value}"
                    ;;
            esac
        fi
    done < $tredlyFile
    
    # set some default values if they werent set
    if [[ -z "${_CONF_TREDLYFILE[containerVersion]}" ]]; then
        _CONF_TREDLYFILE[containerVersion]=1
    fi
    if [[ -z "${_CONF_TREDLYFILE[startOrder]}" ]]; then
        _CONF_TREDLYFILE[startOrder]=1
    fi
    if [[ -z "${_CONF_TREDLYFILE[replicate]}" ]]; then
        _CONF_TREDLYFILE[replicate]="no"
    fi
    if [[ -z "${_CONF_TREDLYFILE[layer4Proxy]}" ]]; then
        _CONF_TREDLYFILE[layer4Proxy]="no"
    fi
    if [[ -z "${_CONF_TREDLYFILE[maxCpu]}" ]]; then
        _CONF_TREDLYFILE[maxCpu]="unlimited"
    fi
    if [[ -z "${_CONF_TREDLYFILE[maxHdd]}" ]]; then
        _CONF_TREDLYFILE[maxHdd]="unlimited"
    fi
    if [[ -z "${_CONF_TREDLYFILE[maxRam]}" ]]; then
        _CONF_TREDLYFILE[maxRam]="unlimited"
    fi
    ## Skip the validation if need be
    if [[ (-z "${2}") || ("${2}" = false) ]]; then
        tredlyfile_validate
    fi

    return $E_SUCCESS

}

## Checks for the require fields specified in the tredly-host.conf.
## Also checks that at least one of tcpInPorts
## and udpInPorts is set. Lastly, iterates over list of 'fileFolderMapping' and makes sure
## the src folder exists.
##
## Return:
##     - exits with error message if any of the required fields are not present
##
function tredlyfile_validate() {
    ## Use 'required' from the common config to construct the required array
    local -a required
    IFS=',' read -a required <<< "${_CONF_COMMON[required]}"

    ## Validate the contents. Check for required fields
    for p in "${required[@]}"
    do
        if [ -z "${_CONF_TREDLYFILE[${p}]}" ]; then
            exit_with_error "'${p}' is missing or empty and is required. Check Tredlyfile"
        fi
    done

    # if container group is set and startOrder isnt
    if [[ -n "${_CONF_TREDLYFILE[containerGroup]}" ]] && [[ -z "${_CONF_TREDLYFILE[startOrder]}" ]]; then
        exit_with_error "containerGroup is set but startOrder is not. Check Tredlyfile"
    fi
    # if containerGroup is set and replicate isnt
    if [[ -n "${_CONF_TREDLYFILE[containerGroup]}" ]] && [[ -z "${_CONF_TREDLYFILE[replicate]}" ]]; then
        exit_with_error "containerGroup is set but replicate is not. Check Tredlyfile"
    fi

    if [[ ${#_CONF_TREDLYFILE_TCPIN[@]} -eq 0 ]] && [[ ${#_CONF_TREDLYFILE_UDPIN[@]} -eq 0 ]]; then
        exit_with_error "'tcpInPort' and 'udpInPort' are both missing or empty. At least one is required. Check Tredlyfile"
    fi
    
    # make sure that a mount point is specified if persistent storage is selected
    if [[ -n "${_CONF_TREDLYFILE[persistentStorageUUID]}" ]] && ! array_contains_substring _CONF_TREDLYFILE_STARTUP[@] "^persistentMountPoint="; then
        exit_with_error "'persistentStorageUUID' is specified but no mount point specified. Please specify a mount point in your Tredlyfile."
    fi

    ## Check that all the src paths in "fileFolderMapping" exist
    if [[ -n "${_CONF_TREDLYFILE[fileFolderMapping]}" ]]; then
        IFS=',' read -ra PAIR <<< "${_CONF_TREDLYFILE[fileFolderMapping]}"
        regex="^([^ ]+)[[:space:]]([^ ]+)"
        for i in "${PAIR[@]}"; do

            i=$(trim "${i}")

            [[ $i =~ $regex ]]
            src="${BASH_REMATCH[1]}"
            dest=$(rtrim "${BASH_REMATCH[2]}" /)

            ## Make sure the source file or folder exists
            if [[ ! -e "${_CONTAINER_CWD}${src}" ]]; then
                exit_with_error "Source '${src}' does not exist. Check Tredlyfile"
            fi
        done
    fi

    return $E_SUCCESS
}