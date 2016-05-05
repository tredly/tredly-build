#!/usr/local/bin/bash

PREFIX="/usr/local"
MAN=
BINDIR="${PREFIX}/sbin"
LIBDIR="${PREFIX}/lib/tredly/lib"
CONFDIR="${PREFIX}/etc/tredly"
COMMANDSDIR="${PREFIX}/lib/tredly/commands"
INSTALL=/usr/bin/install
MKDIR="mkdir"
RM="rm"
BINMODE="500"

SCRIPTS="tredly"
SCRIPTSDIR="${PREFIX}/BINDIR"

# cleans/uninstalls tredly
function clean() {
    # remove any installed files
    ${RM} -rf "${FILESDIR}"
    ${RM} -f "${BINDIR}/tredly"
    ${RM} -f "${LIBDIR}/"*
    ${RM} -f "${COMMANDSDIR}/"*
    ${RM} -f "${CONFDIR}/"*
}

# returns the directory that the files have been downloaded to
function get_files_source() {
    local TREDLY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    echo "${TREDLY_DIR}"
}


# where the files are located
FILESSOURCE=$( get_files_source )


# loop over the args, looking for clean first
for arg in "$@"; do
    if [[ "${arg}" == "clean" ]]; then
        echo "Cleaning Tredly-Build install"
        clean
    fi
done


# now do it again, but do the install/uninstall
for arg in "$@"; do
    case "${arg}" in
        install)
            echo "Installing Tredly-Build..."
            ${MKDIR} -p "${BINDIR}"
            ${MKDIR} -p "${LIBDIR}"
            ${MKDIR} -p "${CONFDIR}"
            ${MKDIR} -p "${COMMANDSDIR}"
            ${INSTALL} -c -m ${BINMODE} "${FILESSOURCE}/${SCRIPTS}" "${BINDIR}/"
            ${INSTALL} -c "${FILESSOURCE}/lib/"* "${LIBDIR}"
            ${INSTALL} -c "${FILESSOURCE}/commands/"* "${COMMANDSDIR}"

            # keep some files in case of problems
            if [[ -f "${CONFDIR}/tredly-host.conf" ]]; then
                mv -f "${CONFDIR}/tredly-host.conf" "${CONFDIR}/tredly-host.conf.old"
            fi

            # copy the config files
            cp "${FILESSOURCE}/conf/tredly-host.conf.dist" "${CONFDIR}/tredly-host.conf"

            echo "Tredly-Build installed."
            echo -e "\e[38;5;202mNote: Please modify the files in ${CONFDIR} to suit your environment.\e[39m"
            ;;
        uninstall)
            echo "Uninstalling Tredly-Build..."
            # run clean to remove the files
            clean
            echo "Tredly-Build Uninstalled."
            ;;
        clean)
            # do nothing, this is just here to prevent clean being handled as *
            ;;
        *)
            echo "Tredly-Build installer"
            echo ""
            echo "Usage:"
            echo "    `basename "$0"` install: install tredly-build"
            echo "    `basename "$0"` uninstall: uninstall tredly-build"
            echo "    `basename "$0"` install clean: remove all previously installed files and install tredly-build"
            ;;
    esac
done
