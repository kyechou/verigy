#!/bin/bash
#
# Run experiments
#
set -euo pipefail

SCRIPT_DIR="$(dirname $(realpath ${BASH_SOURCE[0]}))"
RESULTS_DIR="$SCRIPT_DIR/results"
cd "$SCRIPT_DIR"
mkdir -p "$RESULTS_DIR"

msg() {
    echo -e "[+] ${1-}" >&2
}

die() {
    echo -e "[!] ${1-}" >&2
    exit 1
}

[ $UID -eq 0 ] && die 'Please run this script without root privilege'

#
# Queue properties
#
name="queue"
prism ctmc.prism ctmc.props -mtbdd \
    -javamaxmem 8g -timeout 1800 \
    -const pkt_rate="1:1:3" \
    -const qlen=10:10:30 \
    -const throughput=2:4:10 \
    -const timer_RRC=3 \
    -const timer_idle=9 \
    -const timer_eDRX=50 \
    -const timer_PSM=20 \
    -const model_time=300 \
    -property fullq,halfq \
    -exportresults "$RESULTS_DIR/$name.results.csv":csv \
    | tee "$RESULTS_DIR/$name.log"

#
# Energy & time properties
#
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
            -const pkt_rate="1/20:3/20:10/20" \
            -const qlen=50 \
            -const throughput=25 \
            -const timer_RRC=${Tarr[0]} \
            -const timer_idle=${Tarr[1]} \
            -const timer_eDRX=${Tarr[2]} \
            -const timer_PSM=${Tarr[3]} \
            -const model_time=$model_time \
            -property cumulative_time,cumulative_energy \
            -exportresults "$RESULTS_DIR/$name.results.csv":csv \
            | tee "$RESULTS_DIR/$name.log"
    done
done

# vim: set ts=4 sw=4 et:
