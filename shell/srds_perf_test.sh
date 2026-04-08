#!/bin/bash

HELP='==============================================================================
Script Name:    srds_perf_test.sh
Description:    Automated Redis performance benchmarking for SRDS(6378) & Redis 6(6379).
Author:         Adam Lee (ldscfe@gmail.com)
Date:           2026-04-08
Version:        1.2.0
License:        MIT
Compatibility:  Linux (GNU), macOS (BSD)

Usage:
    bash srds_perf_test.sh [mode]

Modes:
    1           Test String operations (SET, GET) - Internal
    2           Test List operations (LPUSH, LPOP) - Internal
    3           Test Set operations (SADD, SPOP) - Internal
    4           Test String Batch operations (MSET) - Internal
    5           Test Hash operations (HSET) - Custom
    6           Test Sorted Set operations (ZADD) - Custom

Examples:
    bash srds_perf_test.sh 5
==============================================================================
'
# --- Colors ---
LIB="$HOME/bin/common.sh"; [ -f "$LIB" ] && source "$LIB"
# --- Help ---
if [[ "$1" == "-h" || "$1" == "--help" || "$#" -lt 1 ]]; then
    echo -e "${YELLOW}$HELP${NC}"
    exit 0
fi

case $1 in
  1)
    # String
    CMD="-t set,get"
    ;;
  2)
    # List
    CMD="-t lpush,lpop"
    ;;
  3)
    # Set
    CMD="-t sadd,spop"
    ;;
  4)
    # MSET
    CMD="-t mset"
    ;;
  5)
    # Hash (Custom)
    CMD="hset myhash field:__rand_int__ __rand_int__"
    ;;
  6)
    # ZSet (Custom)
    CMD="zadd myset __rand_int__ member:__rand_int__"
    ;;
  *)
    # Default: String
    CMD="-t set,get"
    ;;
esac


BM="redis-benchmark -h 127.0.0.1 -r 10000 -n 100000 --csv"

commands_srds=(
    "${BM} -p 6378 -c 1 -P 1 ${CMD}"
    "${BM} -p 6378 -c 5 -P 1 ${CMD}"
    "${BM} -p 6378 -c 50 -P 1 ${CMD}"
    "${BM} -p 6378 -c 50 -P 16 ${CMD}"
)
commands_redis6=(
    "${BM} -p 6379 -c 1 -P 1 ${CMD}"
    "${BM} -p 6379 -c 5 -P 1 ${CMD}"
    "${BM} -p 6379 -c 50 -P 1 ${CMD}"
    "${BM} -p 6379 -c 50 -P 16 ${CMD}"
)

for cmd in "${commands_srds[@]}"; do
    echo -e "${BLUE}SRDS: $cmd"
    echo -e "----------------------------------------${GREEN}"
    eval $cmd
    echo -e "${NC}"
done

echo "========================================"

for cmd in "${commands_redis6[@]}"; do
    echo -e "${BLUE}Redis6: $cmd"
    echo -e "----------------------------------------${GREEN}"
    eval $cmd
    echo -e "${NC}"
done
