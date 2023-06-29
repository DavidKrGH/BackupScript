#!/bin/bash
# BackupScripts version 1.0.3
#################################### License ####################################
# MIT License Copyright (c) 2023 David Krumm                                    #
# All rights reserved.                                                          #
#                                                                               #
# This source code is licensed under the MIT license found in the               #
# LICENSE file in the root directory of this source tree.                       #
#################################################################################
#================================ BackupScripts ================================#
#################################################################################
                                                                                #     
job_name="ChangeMeToUniqueName"                                                 # Unique job name. Do not use space or underscore!!!
                                                                                #
home_path="/PATH/TO/BackupScripts"                                              # Path to BackupScripts directory. Does not support Docker volume propagation!
                                                                                #
hostname="HOSTNAME"                                                             # Name to identify your System in Snapshots
                                                                                #
notification_after_completion="false"                                           # (true/false) The notification system must be set up. See documentation.
                                                                                #
############################## Restic ###########################################
                                                                                #
source="/PATH/TO/DATA:ro"                                                       # Source directory to be backed up. Support for Docker volume propagation! E.G. "/PATH/TO/DATA:rw,slave" ro=read-only, rw=read-write 
                                                                                #
repo="/PATH/TO/REPO"                                                            # Path to the backup repository. Support for Docker volume propagation! E.G. "/PATH/TO/REPO:rw,slave" ro=read-only, rw=read-write 
                                                                                #
password_file="restic-repo.password"                                            # File in Config/ResticConfig. Insert yor repository password first.
                                                                                #
tags="--tag FirstTag --tag SecondTag"                                           # Tags to be applied to the backup snapshots
                                                                                #
filter_file="DefaultResticFilter.txt"                                           # Filter file to exclude specific files or directories from the backup
                                                                                #
restic_options=""                                                               # Additional options specific to Restic
                                                                                #
############################## Snapshot Rotation                                #     
                                                                                # Schedule for the execution of the Restic forget process:
schedule_forget="always"                                                        # "never", "always", "weekly: Mon, Tue, Wed, Thu, Fri, Sat, Sun", "monthly: 15"
                                                                                # Executed only once per day if the weekly or monthly pattern is used.
                                                                                #
hourly_for="12h"                                                                # Number of hours to keep hourly snapshots
daily_for="7d"                                                                  # Number of days to keep daily snapshots
weekly_for="3m"                                                                 # Number of weeks to keep weekly snapshots
monthly_for="1y"                                                                # Number of months to keep monthly snapshots
yearly_for="5y"                                                                 # Number of years to keep yearly snapshots
                                                                                #
############################## Prune                                            #
                                                                                # Schedule for the execution of the Restic forget process:
schedule_prune="weekly: Mon, Wed, Sat"                                          # "never", "always", "weekly: Mon, Tue, Wed, Thu, Fri, Sat, Sun", "monthly: 15"
                                                                                # Executed only once per day if the weekly or monthly pattern is used.
############################## Docker ###########################################
                                                                                #
handle_docker="false"                                                           # (true/false) Whether to handle Docker containers during backup
                                                                                #
reverse_on_start="true"                                                         # (true/false) Whether to reverse the order of container_list on startup
                                                                                #
stop_start_remaining_container="false"                                          # (true/false) Whether to stop and start remaining containers after the containers in container_list have stopped
                                                                                #
container_list=("1. Container" "2. Container" "3. Container")                   # List of containers to be stopped in a specified order. Stopping takes place in the order of the list
                                                                                #
############################## Rclone ###########################################
                                                                                #
schedule_rclone="monthly, 10"                                                   # Schedule for running Rclone: "never", "always", "weekly: Mon, Tue, Wed, Thu, Fri, Sat, Sun", "monthly: 15" 
                                                                                # Executed only once per day if the weekly or monthly pattern is used.
                                                                                #
dest_remote="RemoteName:/PATH/ON/REMOTE"                                        # Destination remote for Rclone. Does not support Docker volume propagation!
                                                                                #
log_level="INFO"                                                                # Log level for Rclone: "DEBUG", "INFO", "NOTICE", "ERROR"
                                                                                #
rclone_options=""                                                               # Additional options specific to Restic
                                                                                #
#################################################################################
#     Don't change anything from here if you don't know what you are doing      # 
#################################################################################
              

 

############################## Functions ########################################

call_notifier() {
    local channel="$1"
    local args="$2"
    local mes="$3"
    "$home_path/Executor/Notifier" "$home_path" "$job_name" "$channel" "$args" "$mes"
}

evaluate_lock() {
    local lock_reason="running"
    "$home_path/Executor/LockHandler" "$home_path" "check" "$job_name" "$lock_reason"
    exit_code=$?
    if [[ $exit_code -eq 99 ]]; then    # Lock file is set. Exit script normaly
        call_notifier "2" "normal" "Lock for 'running' is already set"
        exit 0
    elif [[ $exit_code -ne 0 ]]; then   # Faild to evaluate. Exit with error
        call_notifier "1" "" "ERROR $job_name: Failed to evaluate '$lock_reason'"
        call_notifier "2" "warning" "ERROR $job_name: Failed to evaluate '$lock_reason'"
        exit 1
    fi                                  # No lock active. Lock has been set. Execution continues
}

release_lock() {
    local lock_reason="running"
    "$home_path/Executor/LockHandler" "$home_path" "release" "$job_name" "$lock_reason"
    exit_code=$?
    if [[ "$exit_code" != 0 ]]; then    # Faild to evaluate. Exit with error
        call_notifier "2" "" "ERROR $job_name: Failed to release '$lock_reason'"
    fi
}

############################## Jobs #############################################

call_notifier "-1" "" ""
call_notifier "1" "" "Starting '$job_name' ..."

evaluate_lock

############################## Backup 

"$home_path/Executor/ResticBackupExec" "$home_path" "$job_name" "$hostname" \
"$source" "$repo" "$password_file" "$filter_file" "$tags" "$restic_options" \
"$handle_docker" "$stop_start_remaining_container" "$reverse_on_start" "${container_list[@]}"

backup_exit_code=$?
# If backup fails
if [[ "$backup_exit_code" != 0 ]]; then
    call_notifier "2" "warning" "Execution of 'Restic Backup' failed"
    release_lock
    exit 1
fi

############################## Forget

keep_rules="--keep-within-hourly $hourly_for --keep-within-daily $daily_for"
keep_rules+=" --keep-within-weekly $weekly_for --keep-within-monthly $monthly_for"
keep_rules+=" --keep-within-yearly $yearly_for"

"$home_path/Executor/ResticForgetExec" "$home_path" "$job_name" "$repo" \
"$password_file" "$schedule_forget" "$keep_rules"

forget_exit_code=$?
# If Forget fails
if [[ "$forget_exit_code" != 0 ]]; then
    call_notifier "2" "warning" "Execution of 'Forget' failed"
    release_lock
    exit 1
fi

############################## Prune

"$home_path/Executor/ResticPruneExec" "$home_path" "$job_name" "$repo" \
"$password_file" "$schedule_prune"

prune_exit_code=$?
# If Prune fails
if [[ "$prune_exit_code" != 0 ]]; then
    call_notifier "2" "warning" "Execution of 'Prune' failed"
    release_lock
    exit 1
fi

############################## Rclone 

"$home_path/Executor/RcloneExec" "$home_path" "$job_name" "$schedule_rclone" "$repo" "$dest_remote" \
"" "--log-file /LogFiles/${job_name}_logging.log --log-level=$log_level" "$rclone_options"

rclone_exit_code=$?
# If Rclones fails
if [[ "$rclone_exit_code" != 0 ]]; then
    call_notifier "2" "warning" "Execution of 'Rclone' failed"
    release_lock
    exit 1
fi

############################## Finished

if [[ "$notification_after_completion" = "true" ]]; then
    call_notifier "2" "normal" "Execution successfully finished"
fi
release_lock
call_notifier "1" "" ""
call_notifier "1" "" "Finished '$job_name'"
call_notifier "-1" "" ""

#################################################################################
#                                      End                                      #
#################################################################################