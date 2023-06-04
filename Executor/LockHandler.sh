#!/bin/bash

#################################### License ####################################
# MIT License Copyright (c) 2023 David Krumm
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
################################# Parameters ################################
home_path="$1"                                                              # Path to the BackupScript directory
check_or_release="$2"                                                       # Command: "Check" or "Release" lock files
job_name="$3"                                                               # Name of the current job
lock="$4"                                                                   # Reason for the lock
################################# Variables ################################

# Set lock file path
lock_file="$home_path/ActiveLocks/${job_name}_${lock}_$(date +%Y%m%d).lock"
mkdir -p "$(dirname "$lock_file")"

################################# Funktions #################################

call_notifier() {
    local importance="$1"
    local mes="$2"
    "$home_path/Executor/Notifier.sh" "$home_path" "$job_name" "$importance" "$mes"
}

check_lock() {

    if [[ -f "$lock_file" ]]; then          # Check if lock file exists
        call_notifier "-1" ""
        call_notifier "1" "Lock for '$lock' is already set"
        call_notifier "-1" ""
        exit 99
    else                                    # Create lock file if none exists
        touch "$lock_file"
        call_notifier "-1" ""
        call_notifier "1" "Set lock for '$lock'"
        call_notifier "-1" ""
        exit 0
    fi
}

# Function to delete old lock files
delete_lock_files() {
    # Get the current date
    current_date=$(date +%Y%m%d)

    # Find all lock files with the same job name
    find "$home_path/ActiveLocks" -name "${job_name}_*.lock" -type f |
    while IFS= read -r file; do
        # Extract the lock part from the lock file name
        file_lock=$(basename "$file" | sed -n 's/.*_\([^_]*\)_\([0-9]\{8\}\).lock$/\1/p')
        # Extract the date part from the lock file name
        file_date=$(basename "$file" | sed -n 's/.*_\([^_]*\)_\([0-9]\{8\}\).lock$/\2/p')
        if [[ "$file_lock" == "$lock" ]]; then
            if [[ "$file_lock" == "running" ]]; then
                # Delete the lock file if the lock is set to "running"
                rm "$file"
                call_notifier "-1" ""
                call_notifier "1" "Delete Lock 'running' for '$job_name'"
                call_notifier "-1" ""
            elif [[ "$file_date" -lt "$current_date" ]]; then
                # Delete the lock file if the date is older than today
                rm "$file"
                call_notifier "-1" ""
                call_notifier "1" "Delete Lock '$lock'"
                call_notifier "-1" ""
            fi
        fi
    done
    return 0
}

################################## Jobs #####################################

if [[ "$check_or_release" == "check" ]]; then               # Call check function
    check_lock
elif [[ "$check_or_release" == "release" ]]; then           # Call release function
    delete_lock_files
else                                                        # Raise error. Wrong command
    call_notifier "2" "ERROR: $job_name LockHandler command '$check_or_release' unknown"
    exit 1
fi
