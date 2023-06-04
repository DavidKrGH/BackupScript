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
importance="$3"                                                             # Level of importance of the message
message="$4"                                                                # Message to send
################################# Variables ################################
timestamp="$(date +%F_%T)"                                                  # Log timestamp
# Path to logfile
log_file="$home_path/LogFiles/${job_name}_logging.log"                      # Path to log file
mkdir -p "$(dirname "$log_file")"
#############################################################################


#############################################################################
#                  Adjust the code below to suit your needs                 # 
#############################################################################
################################# Interfaces ################################

to_terminal() {
    # Send message to log and log file
    local msg="$1"
    echo "$msg"
}

to_logfile() {
    # Send message to log and log file
    local msg="$1"
    echo "$msg" >> "$log_file"
}

to_system_notification() {                                                           #
    # Sending a high priority message to the system notification, log and log file   #
    local msg="$1"                                                                   #
    #"/usr/local/emhttp/webGui/scripts/notify" -i warning -s "$job_name" -d "$msg"   # Uncommend this if you use a Unraid System
}                                                                                    # Replace the command to adapt the function to your system

to_mail() {                                                                     
    local msg="$1"
    #
    # Enter your commands for sending mails here
    #
}

################################# Send ######################################

if [[ "$importance" == -1 ]]; then      # Create an empty line
    to_terminal ""
    to_logfile ""
    
elif [[ "$importance" == 0 ]]; then
    to_terminal "$timestamp - ERROR: No level set for Notification"
    to_logfile "$timestamp - ERROR: No level set for Notification"
    exit 1

elif [[ "$importance" == 1 ]]; then     # Message to logfile
    to_terminal "$timestamp - $message"
    to_logfile "$timestamp - $message"

elif [[ "$importance" == 2 ]]; then     # Message to the system notification
    to_terminal "$timestamp - $message"
    to_logfile "$timestamp - $message"
    to_system_notification "$message"      
fi