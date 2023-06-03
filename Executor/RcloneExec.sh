#!/bin/bash

################################# Parameters ################################
home_path="$1"                                                              # Path to the BackupScript directory
job_name="$2"                                                               # Name of the current job
schedule="$3"                                                               # Pattern for the submission of a timetable for execution
source="$4"                                                                 # Directory to be backed up
destination="$5"                                                            # Destination directory of the data backup
filter_options="$6"                                                         # Settings for filtering files
logging_options="$7"                                                        # Settings for the logging of rclone
options="$8"                                                                # Additional rclone options
################################# Funktions #################################

call_notifier() {
    local importance="$1"
    local mes="$2"
    "$home_path/Executor/Notifier.sh" "$home_path" "$job_name" "$importance" "$mes"
}

evaluate_lock() {
    local lock_reason="rclone"
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
    local lock_reason="rclone"
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

    if [[ "$input" == "always" ]]; then
        release_lock
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

################################# Backup ####################################

# Check schedule for execution 
if check_date "$schedule"; then     # Continue with the backup
    call_notifier "-1" ""
    call_notifier "1" "Starting 'rclone' job to $destination"
    call_notifier "1" ""
else                                # Stop execution
    call_notifier "-1" ""
    call_notifier "1" "Skip 'rclone' because of schedule '$schedule'."
    call_notifier "-1" ""
    release_lock                    # Release lock when scheduled day is over
    exit 0
fi

cmd="docker run --rm --name RcloneBackup \
    --volume $home_path/Config/RcloneConfig:/config/rclone \
    --volume $home_path/LogFiles:/LogFiles \
    --volume $home_path/FilterFiles/RcloneFilter:/FilterFiles \
    --volume $source:/source \
    --user $(id -u):$(id -g) \
    rclone/rclone sync /source $destination \
    $filter_options $logging_options $options"

# progress message
call_notifier "1" ""
call_notifier "1" "Backup in progress ... "
call_notifier "1" ""
call_notifier "1" "$cmd"
call_notifier "1" ""

eval $cmd
exit_code=$?

################################# Evaluation ################################

if [[ "$exit_code" == 0 ]]; then
    call_notifier "1" "Completed 'backup' job to '$destination' successfully"
    call_notifier "-1" ""
    exit 0
else
    call_notifier "2" "ERROR $job_name: Rclone to '$destination' failed with exit_code=$exit_code"
    exit 1
fi