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

_DEBUG=false

## Turns on debugging (`set -x`) and sets _DEBUG to true
##
## Arguments: none
## Usage: enable_debugging
## Return: none.
function enable_debugging() {
    set -x
    _DEBUG=true
}

## Turns off debugging (`set +x`) and sets _DEBUG to false
##
## Arguments: none
## Usage: disable_debugging
## Return: none.
function disable_debugging() {
    set +x
    _DEBUG=false
}

## Toggles the _DEBUG values by calling either `enable_debugging`
## or `disable_debugging`
##
## Arguments: none
##
## Usage:
##     toggle_debugging
##
## Return: none.
function toggle_debugging() {
    if [ "$_DEBUG" == false ]; then
        enable_debugging

    else
        disable_debugging
    fi
}