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

# success/failure return codes
declare E_SUCCESS=0
declare E_ERROR=1
declare E_FATAL=2

# verbose mode
declare _VERBOSE_MODE=false

# ZFS Dataset locations
declare ZFS_ROOT="zroot"
declare ZFS_TREDLY_DATASET="${ZFS_ROOT}/tredly"
declare ZFS_TREDLY_CONTAINER_DATASET="${ZFS_TREDLY_DATASET}/containers"
declare ZFS_TREDLY_DOWNLOADS_DATASET="${ZFS_TREDLY_DATASET}/downloads"
declare ZFS_TREDLY_LOG_DATASET="${ZFS_TREDLY_DATASET}/log"
declare ZFS_TREDLY_PARTITIONS_DATASET="${ZFS_TREDLY_DATASET}/ptn"
declare ZFS_TREDLY_PERSISTENT_DATASET="${ZFS_TREDLY_DATASET}/persistent"
declare ZFS_TREDLY_RELEASES_DATASET="${ZFS_TREDLY_DATASET}/releases"

# ZFS Mount locations
declare TREDLY_MOUNT="/tredly"
declare TREDLY_CONTAINER_MOUNT="${TREDLY_MOUNT}/containers"
declare TREDLY_DOWNLOADS_MOUNT="${TREDLY_MOUNT}/downloads"
declare TREDLY_LOG_MOUNT="${TREDLY_MOUNT}/log"
declare TREDLY_PARTITIONS_MOUNT="${TREDLY_MOUNT}/ptn"
declare TREDLY_PERSISTENT_MOUNT="${TREDLY_MOUNT}/persistent"
declare TREDLY_RELEASES_MOUNT="${TREDLY_MOUNT}/releases"

# zfs properties
declare ZFS_PROP_ROOT="com.tredly"

# name of the default partition within ZFS_TREDLY_PARTITIONS_DATASET/TREDLY_PARTITIONS_MOUNT
declare TREDLY_DEFAULT_PARTITION="default"
declare TREDLY_CONTAINER_DIR_NAME="cntr"
declare TREDLY_PTN_DATA_DIR_NAME="data"

# Nginx Proxy
declare NGINX_BASE_DIR="/usr/local/etc/nginx"
declare NGINX_UPSTREAM_DIR="${NGINX_BASE_DIR}/upstream"
declare NGINX_SERVERNAME_DIR="${NGINX_BASE_DIR}/server_name"
declare NGINX_SSLCONFIG_DIR="${NGINX_BASE_DIR}/sslconfig"
declare NGINX_ACCESSFILE_DIR="${NGINX_BASE_DIR}/access"

# Unbound
declare UNBOUND_ETC_DIR="/usr/local/etc/unbound"
declare UNBOUND_CONFIG_DIR="/usr/local/etc/unbound/configs"

# Tredly onstop script
declare TREDLY_ONSTOP_SCRIPT="/etc/rc.onstop"

# IPFW Scripts
declare IPFW_SCRIPT="/usr/local/etc/ipfw.rules"
declare IPFW_FORWARDS="/usr/local/etc/ipfw.portforwards"

# Main IPFW rules within containers
declare CONTAINER_IPFW_SCRIPT="/usr/local/etc/ipfw.rules"
declare CONTAINER_IPFW_PARTITION_SCRIPT="/usr/local/etc/ipfw.partition"

## what to rename the interface to within the container
declare VNET_CONTAINER_IFACE_NAME="vnet0"

# Supported FreeBSD Releases
declare -a RELEASES_SUPPORTED
RELEASES_SUPPORTED+=('10.3-RELEASE')

# Base directories for container
declare -a BASEDIRS
BASEDIRS+=('bin')
BASEDIRS+=('boot')
BASEDIRS+=('lib')
BASEDIRS+=('libexec')
BASEDIRS+=('rescue')
BASEDIRS+=('sbin')
BASEDIRS+=('usr/bin')
BASEDIRS+=('usr/include')
BASEDIRS+=('usr/lib')
BASEDIRS+=('usr/libexec')
BASEDIRS+=('usr/ports')
BASEDIRS+=('usr/sbin')
BASEDIRS+=('usr/share')
BASEDIRS+=('usr/src')
BASEDIRS+=('usr/libdata')
BASEDIRS+=('usr/lib32')

# provide a list of technicaloptions which we will accept from the Tredlyfile
declare -a VALID_TECHNICAL_OPTIONS

VALID_TECHNICAL_OPTIONS+=('securelevel')
VALID_TECHNICAL_OPTIONS+=('devfs_ruleset')
VALID_TECHNICAL_OPTIONS+=('enforce_statfs')
VALID_TECHNICAL_OPTIONS+=('children_max')
VALID_TECHNICAL_OPTIONS+=('allow_set_hostname')
VALID_TECHNICAL_OPTIONS+=('allow_sysvipc')
VALID_TECHNICAL_OPTIONS+=('allow_raw_sockets')
VALID_TECHNICAL_OPTIONS+=('allow_chflags')
VALID_TECHNICAL_OPTIONS+=('allow_mount')
VALID_TECHNICAL_OPTIONS+=('allow_mount_devfs')
VALID_TECHNICAL_OPTIONS+=('allow_mount_nullfs')
VALID_TECHNICAL_OPTIONS+=('allow_mount_procfs')
VALID_TECHNICAL_OPTIONS+=('allow_mount_tmpfs')
VALID_TECHNICAL_OPTIONS+=('allow_mount_zfs')
VALID_TECHNICAL_OPTIONS+=('allow_quotas')
VALID_TECHNICAL_OPTIONS+=('allow_socket_af')
VALID_TECHNICAL_OPTIONS+=('exec_prestart')
VALID_TECHNICAL_OPTIONS+=('exec_poststart')
VALID_TECHNICAL_OPTIONS+=('exec_prestop')
VALID_TECHNICAL_OPTIONS+=('exec_stop')
VALID_TECHNICAL_OPTIONS+=('exec_clean')
VALID_TECHNICAL_OPTIONS+=('exec_timeout')
VALID_TECHNICAL_OPTIONS+=('exec_fib')
VALID_TECHNICAL_OPTIONS+=('stop_timeout')
VALID_TECHNICAL_OPTIONS+=('mount_devfs')
VALID_TECHNICAL_OPTIONS+=('mount_fdescfs')