#!/bin/bash
#
# Run experiments
#
set -euo pipefail

SCRIPT_DIR="$(dirname $(realpath ${BASH_SOURCE[0]}))"
RESULTS_DIR="$SCRIPT_DIR/results"
cd "$SCRIPT_DIR"

msg() {
    echo -e "[+] ${1-}" >&2
}

die() {
    echo -e "[!] ${1-}" >&2
    exit 1
}

[ $UID -eq 0 ] && die 'Please run this script without root privilege'

mkdir -p "$RESULTS_DIR"

for timers in "3,9,30,10" "3,9,50,20"; do # (4, 6, 10, 10) (RRC, idle, eDRX, PSM)
    Tarr=()
    Tarr+=("$(echo "$timers" | cut -d, -f1)")
    Tarr+=("$(echo "$timers" | cut -d, -f2)")
    Tarr+=("$(echo "$timers" | cut -d, -f3)")
    Tarr+=("$(echo "$timers" | cut -d, -f4)")

    for model_time in 50 150 300; do
        name="timers-$timers.model_time-$model_time"

        prism ctmc.prism ctmc.props -mtbdd \
            -javamaxmem 8g -timeout 1800 \
            -const pkt_rate="1/30:1/30:3/30" \
            -const qlen=10:40:100 \
            -const throughput=10:10:30 \
            -const timer_RRC=${Tarr[0]} \
            -const timer_idle=${Tarr[1]} \
            -const timer_eDRX=${Tarr[2]} \
            -const timer_PSM=${Tarr[3]} \
            -const model_time=$model_time \
            -exportresults "$RESULTS_DIR/$name.results.csv":csv \
            | tee "$RESULTS_DIR/$name.log"
        exit
    done
done


# vim: set ts=4 sw=4 et:
