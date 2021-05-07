#!/bin/bash
#
# Run experiments
#
set -euo pipefail

SCRIPT_DIR="$(dirname $(realpath ${BASH_SOURCE[0]}))"
cd "$SCRIPT_DIR"

msg() {
    echo -e "[+] ${1-}" >&2
}

die() {
    echo -e "[!] ${1-}" >&2
    exit 1
}

[ $UID -eq 0 ] && die 'Please run this script without root privilege'


prism ctmc.prism ctmc.props -mtbdd -exportresults ctmc.results.csv:csv


# vim: set ts=4 sw=4 et:
