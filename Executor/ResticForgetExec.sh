#!/bin/bash
# BackupScripts version 1.0.2
#################################### License ################################
# MIT License Copyright (c) 2023 David Krumm                                #
# All rights reserved.                                                      #
#                                                                           #
# This source code is licensed under the MIT license found in the           #
# LICENSE file in the root directory of this source tree.                   #
################################# Parameters ################################
home_path="$1"                                                              # Path to the BackupScript directory
job_name="$2"                                                               # Name of the current job
repo="$3"                                                                   # Destination directory of the data backup
password_file="$4"                                                          # Password file of restic repo
schedule="$5"                                                               # Pattern for the submission of a timetable for execution
keep_rules="$6"                                                             # Rules for keeping snapshots
######################### Docker Volume Propagation #########################

if [[ $repo == *":"* ]]; then
    repo_prop=":$(echo "$repo" | cut -d ":" -f 2)"
    repo=$(echo "$repo" | cut -d ":" -f 1)
else
    repo_prop=""
fi

################################## Funktions ################################

call_notifier() {
    local importance="$1"
    local mes="$2"
    "$home_path/Executor/Notifier.sh" "$home_path" "$job_name" "$importance" "$mes"
}

evaluate_lock() {
    local lock_reason="forget"
    "$home_path/Executor/LockHandler.sh" "$home_path" "check" "$job_name" "$lock_reason"
    exit_code=$?
    if [[ $exit_code -eq 99 ]]; then    # Lock file is set. Exit script normaly
        exit 0
    elif [[ $exit_code -ne 0 ]]; then   # Faild to evaluate. Exit with error
        call_notifier "1" "ERROR $job_name: Failed to evaluate '$lock_reason'"
        exit 1
    fi                                  # No lock active. Lock has been set. Execution continues
}

release_lock() {
    local lock_reason="forget"
    "$home_path/Executor/LockHandler.sh" "$home_path" "release" "$job_name" "$lock_reason"
    exit_code=$?
    if [[ "$exit_code" != 0 ]]; then    # Faild to evaluate. Exit with error
        call_notifier "2" "ERROR $job_name: Failed to release '$lock_reason'"
    fi
}

check_date() {
# Usage: check_date <pattern>
#  - <pattern> can be one of the following:
#     - "always": Execute the function every time it is called.
#     - "weekly: Mon, Tue, Wed, Thu, Fri, Sat, Sun": Execute the function on the specified days of the week.
#       Replace the example days with your desired days.
#     - "monthly: <day>": Execute the function on the specified day of the month.
#       Replace <day> with the desired day of the month (e.g., "1" for the 1st day, "15" for the 15th day).
#     - "never": Never execute the function.
    local input="$1"
    local current_date=$(date +%F)                              # Get current date in YYYY-MM-DD format
    release_lock                                                # Release outdated locks first

    if [[ "$input" == "always" ]]; then
        return 0                                                # Match found, return true
    elif [[ "$input" == weekly* ]]; then
        local days="${input#weekly: }"                          # Extract the days of the week
        local current_day_of_week=$(date +%a)                   # Get current day of the week (e.g., Mon, Tue)

        if [[ "$days" == *"$current_day_of_week"* ]]; then
            evaluate_lock                                       # Check the current lock status
            return 0                                            # Match found, return true
        fi
    elif [[ "$input" == monthly* ]]; then
        local day_of_month="${input#monthly: }"                 # Extract the day of the month
        local current_day_of_month=$(date +%d)                  # Get current day of the month

        if [[ "$current_day_of_month" -eq "$day_of_month" ]]; then
            evaluate_lock                                       # Check the current lock status
            return 0                                            # Match found, return true
        fi
    elif [[ "$input" == "never" ]]; then
        return 1                                                # Match found, return false
    fi

    return 1                                                    # No match found, return false
}

################################### Forget ##################################

# Check schedule for execution 
if check_date "$schedule"; then     # Continue with the backup
    call_notifier "1" ""
    call_notifier "1" "Starting 'forget' job of '$repo'"
else                                # Stop execution
    call_notifier "1" ""
    call_notifier "1" "Skip 'forget' because of schedule '$schedule'"
    release_lock                    # Release lock when scheduled day is over
    exit 0
fi

cmd="docker run --rm --name ResticForget \
    --volume $home_path:/home \
    --volume $repo:/repo$repo_prop \
    --user $(id -u):$(id -g) \
    restic/restic \
    --password-file=/home/Config/ResticConfig/$password_file \
    -r /repo forget $keep_rules"

# progress message
call_notifier "1" ""
call_notifier "1" "Forget in progress ... "
call_notifier "1" "Keep-Rules: '$keep_rules'"
call_notifier "1" ""
call_notifier "1" "$cmd"

output=$(eval $cmd)
call_notifier "-1" "$output"
exit_code=$?

################################# Evaluation ################################

if [[ "$exit_code" == 0 ]]; then
    call_notifier "1" ""
    call_notifier "1" "Completed 'forget' job of '$repo' successfully"
    exit 0
else
    call_notifier "-1" ""
    call_notifier "2" "ERROR $job_name:  Forget of '$repo' failed with exit_code=$exit_code"
    call_notifier "-1" ""
    exit 1
fi