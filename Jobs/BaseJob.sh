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
JOB_NAME="ChangeMeToUniqueName"                                                 # Unique job name. Do not use space or underscore!!!
                                                                                #
HOME_PATH="/PATH/TO/BackupScripts"                                              # Path to BackupScripts directory. Does not support Docker volume propagation!
                                                                                #
hostname="HOSTNAME"                                                             # Name to identify your System in Snapshots
                                                                                #
notification_after_completion="false"                                           # (true/false) The notification system must be set up. See documentation.
                                                                                #
############################## Restic ###########################################
                                                                                #
                                                                                # Schedule for the execution of the Restic forget process:
schedule_backup="always"                                                        # "never", "always", "weekly: Mon, Tue, Wed, Thu, Fri, Sat, Sun", "monthly: 15"
                                                                                # Executed only once per day if the weekly or monthly pattern is used.
                                                                                #
source="/PATH/TO/DATA:ro"                                                       # Source directory to be backed up. Support for Docker volume propagation! E.G. "/PATH/TO/DATA:rw,slave" ro=read-only, rw=read-write 
                                                                                #
repo="/PATH/TO/REPO:rw,slave"                                                   # Path to the backup repository. Support for Docker volume propagation! E.G. "/PATH/TO/REPO:rw,slave" ro=read-only, rw=read-write 
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
schedule_rclone="monthly: 10"                                                   # Schedule for running Rclone: "never", "always", "weekly: Mon, Tue, Wed, Thu, Fri, Sat, Sun", "monthly: 15" 
                                                                                # Executed only once per day if the weekly or monthly pattern is used.
                                                                                #
dest_remote="RemoteName:/PATH/ON/REMOTE"                                        # Destination remote for Rclone. Does not support Docker volume propagation!
                                                                                #
log_level="INFO"                                                                # Log level for Rclone: "DEBUG", "INFO", "NOTICE", "ERROR"
                                                                                #
rclone_options=""                                                               # Additional options specific to Restic
                                                                                #
#################################################################################

              




#################################################################################
#                                                                               #
#     Don't change anything from here if you don't know what you are doing      #
#                                                                               #
#################################################################################



########################## Setup File Paths #####################################

NOTIFIER="$HOME_PATH/Executor/Notifier"
ConditionHandler="$HOME_PATH/Executor/ConditionHandler"
ResticBackupExec="$HOME_PATH/Executor/ResticBackupExec"
ResticForgetExec="$HOME_PATH/Executor/ResticForgetExec"
ResticPruneExec="$HOME_PATH/Executor/ResticPruneExec"
RcloneExec="$HOME_PATH/Executor/RcloneExec"

############################## Export Env Variables #############################

export HOME_PATH JOB_NAME NOTIFIER

############################## Check Preconditions ##############################

preconditions=0
check_executable() {
    local file=$1
    if [ ! -f "$file" ]; then
        echo "ERROR: $file does not exist."
        preconditions=1
    elif [ ! -x "$file" ]; then
        echo "ERROR: $file exists but is not executable."
        echo "-> Read the instructions and the setup files in the 'BackupScripts/SetupInstruction' directory."
        echo "-> Use 'chmod +x $file' to give the file the required rights."

        preconditions=1
    fi
}

check_directory_exists() {
    local directory=$(echo "$1" | cut -d':' -f1)
    if [ ! -d "$directory" ]; then
    echo "ERROR: The directory $directory does not exist."
    preconditions=1
    fi
}

check_directory_exists "$HOME_PATH"
check_directory_exists "$source"
check_directory_exists "$repo"

check_executable "$NOTIFIER"
check_executable "$ConditionHandler"
check_executable "$ResticBackupExec"
check_executable "$ResticForgetExec"
check_executable "$ResticPruneExec"
check_executable "$RcloneExec"

if [[ $preconditions != 0 ]]; then
    exit 1
fi

############################## Jobs #############################################

$NOTIFIER --channel "file" --timestamps "false"
$NOTIFIER --channel "file" --message "Starting '$JOB_NAME' ..."

# Check if jobs is already executed
$ConditionHandler --task "evaluate" --type "execution"
job_is_already_executed=$?
if [[ "$job_is_already_executed" == 99 ]]; then
    exit 0                                          # Job is already executed.
elif [[ "$job_is_already_executed" == 1 ]]; then
    exit 1                                          # Something went wrong
fi

############################## Backup 

# Evaluate schedule
$ConditionHandler --task "evaluate" --type "lock" --process "Backup" --schedule "$schedule_backup"
evaluation=$?

if [[ "$evaluation" == 0 ]]; then
    $ResticBackupExec "$hostname" "$source" "$repo" "$password_file" "$filter_file" "$tags" "$restic_options" \
    "$handle_docker" "$stop_start_remaining_container" "$reverse_on_start" "${container_list[@]}"
    backup_exit_code=$?
fi

# If evaluation or ResticForgetExec fails
if [[ "$evaluation" == 1 || "$backup_exit_code" == 1 ]]; then
    $ConditionHandler --task "release" --type "execution"
    exit 1
fi

############################## Forget

# Kombine keep rules
keep_rules="--keep-within-hourly $hourly_for --keep-within-daily $daily_for"
keep_rules+=" --keep-within-weekly $weekly_for --keep-within-monthly $monthly_for"
keep_rules+=" --keep-within-yearly $yearly_for"

# Evaluate schedule
$ConditionHandler --task "evaluate" --type "lock" --process "Forget" --schedule "$schedule_forget"
evaluation=$?

if [[ "$evaluation" == 0 ]]; then
    $ResticForgetExec "$repo" "$password_file" "$keep_rules"
    forget_exit_code=$?
fi

# If evaluation or ResticForgetExec fails
if [[ "$evaluation" == 1 || "$forget_exit_code" == 1 ]]; then
    $ConditionHandler --task "release" --type "execution"
    exit 1
fi

############################## Prune

# Evaluate schedule
$ConditionHandler --task "evaluate" --type "lock" --process "Prune" --schedule "$schedule_prune"
evaluation=$?

if [[ "$evaluation" == 0 ]]; then
    $ResticPruneExec "$repo" "$password_file"
    prune_exit_code=$?
fi

# If evaluation or ResticPruneExec fails
if [[ "$evaluation" == 1 || "$prune_exit_code" == 1 ]]; then
    $ConditionHandler --task "release" --type "execution"
    exit 1
fi

############################## Rclone

# Evaluate schedule
$ConditionHandler --task "evaluate" --type "lock" --process "Rclone" --schedule "$schedule_rclone"
evaluation=$?

if [[ "$evaluation" == 0 ]]; then
    $RcloneExec "$repo" "$dest_remote" "" \
    "--log-file /LogFiles/${JOB_NAME}_$(date +'%Y-%m').log --log-level=$log_level" "$rclone_options"
    rclone_exit_code=$?
fi

# If evaluation or ResticPruneExec fails
if [[ "$evaluation" == 1 || "$rclone_exit_code" == 1 ]]; then
    $ConditionHandler --task "release" --type "execution"
    exit 1
fi

############################## Finished

$ConditionHandler --task "release" --type "execution"

completion_channel="file"
if [[ "$notification_after_completion" = "true" ]]; then
    completion_channel="system"
fi
$NOTIFIER --channel "file"
$NOTIFIER --channel "$completion_channel" --args "normal" --message "Execution of '$JOB_NAME' successfully finished"
$NOTIFIER --channel "file" --timestamps "false"

#################################################################################
#                                      End                                      #
#################################################################################