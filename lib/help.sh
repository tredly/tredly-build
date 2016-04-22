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

_HELP="usage -- Tredly script suite.

$(basename "$0") [COMMAND] [FLAGS] [SUBCOMMANDS...]

COMMAND        Name of the script in 'commands' folder to run
FLAGS          See options below
SUBCOMMANDS    Any number of space separated values which are to be consumed
               by the command

Commands:


Options:
    -h|--help|--usage       See help. Contextual to command.
    -d|--debug              Enables debug mode
    -v|--version            Displays version information
    --verbose               Enables verbose output

Examples:

"

## show_help($string, $force=false)
function show_help() {
    if [[ ("${_SHOW_HELP}" == true) || ("$2" == true) ]]; then
        echo "$(basename "$0"): $1"
        exit;
    fi
}