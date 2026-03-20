#!/bin/bash
# This script remotely executes a command on a list of machines.
#
# Usage:
#   rrun <machine_list_file> <command>
#
#   <machine_list_file>: Path to a file containing a list of machine names or IP addresses (one per line).
#   <command>: The command to execute on each machine. This should be quoted to prevent premature expansion.

# Check if the second argument (the command) is provided.
if [ -z "$2" ]; then
    echo "Title  : Remote Run"
    echo "Usage  : rrun <machine_list_file> <command>"
    echo "  <machine_list_file>: Path to a file containing machine names/IPs (one per line)."
    echo "  <command>: The command to execute on each machine (quote it!)."
    echo ""
    echo "Date   : 2018-11-15"
    echo "Author : adaM (ldscfe@gmail.com)"
    exit 0
fi

machine_list_file="$1"
command_to_execute="$2"

# Check if the machine list file exists and is readable.
if [ ! -r "$machine_list_file" ]; then
    echo "Error: Machine list file '$machine_list_file' not found or not readable." >&2
    exit 1
fi

# Executes a command on remote machines.
while IFS= read -r machine; do
    echo "--- Running on: $machine ---"
    ssh -n "root@$machine" "$command_to_execute"
done < "$machine_list_file"

exit 0
