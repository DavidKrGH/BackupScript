#!/bin/bash

#################################### License ################################
# MIT License Copyright (c) 2023 David Krumm                                #
# All rights reserved.                                                      #
#                                                                           #
# This source code is licensed under the MIT license found in the           #
# LICENSE file in the root directory of this source tree.                   #
################################# Parameters ################################
home_path="$1"                                                              # Path to the BackupScript directory
job_name="$2"                                                               # Name of the current job
hostname="$3"                                                               # Set host name for detection of snapshots in the repo
source="$4"                                                                 # Directory to be backed up
repo="$5"                                                                   # Destination directory of the data backup
password_file="$6"                                                          # Password file of restic repo
filter_file="$7"                                                            # Path to filter file
tags="$8"                                                                   # Tags for marking snapshots
options="$9"                                                                # Additional Restic options
################################ Docker Handling ###########################
handle_docker="${10}"                                                       # "true" or "false" to activate or deactivate Docker handling
stop_start_remaining_container="${11}"                                      # "true" to stop and start all "running" containers before backup, "false" to skip
reverse_on_start="${12}"                                                    # "true" to reverse the order of the container_list at start-up
shift 12                                                                    #
container_list=("$@")                                                       # List and sequence of containers to be stopped
################################## Funktions ################################

call_notifier() {
    local importance="$1"
    local mes="$2"
    "$home_path/Executor/Notifier.sh" "$home_path" "$job_name" "$importance" "$mes"
}

reverse_array() {
    local original_array=("$@")
    local reversed_array=()

    for ((i=${#original_array[@]}-1; i>=0; i--)); do
        reversed_array+=("${original_array[i]}")
    done

    echo "${reversed_array[@]}"
}

convert_array_to_print() {
  local array=("$@")
  local result=""
  
  for element in "${array[@]}"; do
    result+=" $element"
  done
  result="${result# }"

  echo "$result"
}

start_stop_containers() {

    local command="$1"
    shift
    local containers=("$@")
    call_notifier "1" "Execute '${command}' for docker containers: '$(convert_array_to_print "${containers[@]}")'"

    for con in "${containers[@]}"; do
        call_notifier "1" "Execute '$command' for '$con' ..."
        docker "$command" "$con"

        # Wait for container to stop/start within a timeout period
        local timeout=30
        local interval=5
        local elapsed=0

        while true; do
            container_status=$(docker inspect -f '{{.State.Status}}' "$con")
            if [[ "$command" == "start" ]]; then
                status="running"
            else
                status="exited"
            fi
            if [[ "$container_status" == "$status" ]]; then
                call_notifier "1" "$con has successfully changed its status"
                break
            fi
            if (( elapsed >= timeout )); then
                call_notifier "-1" ""
                call_notifier "2" "ERROR $job_name: Timeout container '$con' failed to '$command'"
                call_notifier "-1" ""
                exit 1
            fi
            sleep "$interval"
            elapsed=$((elapsed + interval))
        done
        sleep 5
    done
}

################################### Backup ##################################

call_notifier "-1" ""
call_notifier "1" "Starting 'backup' job of '$source'"
call_notifier "1" ""

################################### Stop Docker Container

# Skip if handle_docker is set to false
if [[ "$handle_docker" == "true" ]]; then

    # Stop containers in the container_list
    start_stop_containers "stop" "${container_list[@]}"
    #generate list of remaining running container and stop them
    if [ "$stop_start_remaining_container" = "true" ]; then
        docker_result=$(docker container ls -q)									
        IFS=$'\n' read -rd '' -a containers <<< "$docker_result"
        start_stop_containers "stop" "${containers[@]}"
    fi

else
    call_notifier "1" "" "Container handling deactivated"
fi

################################### Restic Backup

cmd="docker run --rm --name ResticBackup \
    --hostname $hostname \
    --volume $home_path:/home \
    --volume $source:/source \
    --volume $repo:/repo \
    --user $(id -u):$(id -g) \
    restic/restic \
    --password-file=/home/Config/ResticConfig/$password_file \
    -r /repo backup /source $tags \
    --exclude-file=/home/FilterFiles/ResticFilter/$filter_file \
     $options"

# progress message
call_notifier "1" ""
call_notifier "1" "Backup in progress ... "
call_notifier "1" ""
call_notifier "1" "$cmd"
call_notifier "1" ""

eval $cmd
exit_code=$?

################################### Start Docker

# Skip if handle_docker is set to false
if [[ "$handle_docker" == "true" ]]; then

    #start container of generated list
    if [[ "$stop_start_remaining_container" == "true" ]]; then
        start_stop_containers "start" "${containers[@]}"
    fi
    #start container of list "container_list"
    if [[ "$reverse_on_start" == "true" ]]; then
        container_list=($(reverse_array "${container_list[@]}"))
    fi
    start_stop_containers "start" "${container_list[@]}"
fi

################################# Evaluation ################################

if [[ "$exit_code" == 0 ]]; then
    call_notifier "1" "Completed 'backup' job of '$source' successfully"
    call_notifier "-1" ""
    exit 0
else
    call_notifier "2" "ERROR $job_name: Backup of '$source' failed with exit_code=$exit_code"
    exit 1
fi