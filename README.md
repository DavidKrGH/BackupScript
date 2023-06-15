# BackupScripts with Restic and Rclone

## Introduction

Welcome to the Backup Scripts Repository! This small private project aims to create fast, easy and reliable backups. After setup, all you need to do for this is to customize a template for the desired backup job. The powerful tools Restic and Rclone are used for the backup process. Since the official Docker containers of Restic and Rclone are installed automatically, no additional installation is required. All that is needed is a Unix system (Linux or macOS) on which Docker containers can be run.

[Restic](https://restic.net/) is an open source backup utility to protect your data by safely storing and restoring incremental backups. It is easy to use, efficient and reliable and offers a straightforward and flexible solution for backing up and restoring data. With Restic, you can manage your backup process, encrypt your data, store it and ensure the security and accessibility of your important files.

[Rclone](https://rclone.org/) is a versatile command line programme that allows you to synchronise files and directories between different storage locations. Its main purpose is to provide a unified interface for managing and transferring data between different storage platforms such as Google Drive, Dropbox, Amazon S3 or your own remote server. Rclone provides the ability to copy, move and synchronise files, as well as perform advanced operations such as encryption, deduplication and bandwidth control, making it a powerful tool for managing cloud storage.

The combination of Restic and Rclone provides a flexible and robust solution for performing backups that ensures the security and integrity of your data. The scripts provided in this repository simplify the configuration and execution of backup operations and make it easy for you to set up and maintain a reliable backup system.

Only basic command line knowledge is required for use and installation. The automation of the individually created backup jobs can be realised via cron jobs or similar. The scripts are not connected to Restic or Rclone. No liability is assumed for the use or loss of data.

### Features
- Local and remote backups: The scripts support both local and remote backup scenarios. You can choose to back up your data only to a local directory or use different cloud storage providers supported by Rclone.
- Incremental backups: Restic performs efficient incremental backups by identifying changes in files, minimising storage requirements and network bandwidth usage.
- Encryption and security: Restic encrypts your data before it is stored, ensuring privacy and security. If desired, Rclone supports further encryption on the remote system.
- Configurable retention policies: You can customise retention policies to determine how long backups should be kept, balancing storage usage with backup history.
- Docker handeling: The script allows different docker containers to be stopped and then restarted in a defined order for the backup.
- Notification support: Scripts are provided with support for Unraid's notification system. Deviating solutions must be implemented by the user.

## Table of Contents

1. [Project Description](#project-description)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Final Note](#final-note)
4. [License](#license)

## Project Description<a name="project-description"></a>

The BackupScripts project is a set of bash scripts designed to manage local and remote backups with the Restic and Rclone tools. Its main purpose is to provide a flexible and customisable solution for performing incremental backups, rotating snapshots and moving backups to a remote system.

The script is structured with a job template. By customising this template and defining values such as the source directory for the backup, the path to the backup repository, the password file for the repository us, multiple backup jobs can be created easily and flexibly. Since the official Docker containers of the respective projects are used to run Rclone and Restic, no direct installation on the system is necessary.

The script offers functions for handling Docker containers during the backup, so that containers are stopped in a defined order and then restarted. By scheduling the created backup jobs with cron jobs or similar solutions, the entire backup process can be automated.

## Installation<a name="installation"></a>

To install and set up the project, please follow the steps below:

### Requirements ###

- **Operating System**
  - The script is designed to run on a Unix-like operating system such as Linux or macOS.

- **Dependencies**
  - Docker: The host system should have Docker installed and properly configured to run containers.
  - Restic and Rclone: The Docker images Restic and Rclone are required to run the script. If the images are not available locally, they will be downloaded automatically. Make sure the system has access to the internet or provide the images locally.

- **Setup/Job Configuration**
  - You should know how to edit the job template included in the script to define the required values for your backup tasks. These values include the job name, source directory, repository path, password file, tags, and other options specific to Restic and Rclone.
  - For proper backup job setup, you should be familiar with the function of Restic and Rclone. Please refer to the documentation of the programs.
  - Since Restic and Rclone are command line programs, you should have basic knowledge of using the terminal.
  - Since Docker containers are used, you should have basic knowledge of using Docker containers.

- **Access and Permissions**
  - You should have sufficient access rights on the system to run the script and access the required directories, files, and Docker resources.
  - If using Docker containers, you should have the appropriate permissions to interact with Docker, run containers, and manage container networks.

- **Notification Setup**
  - The script provides the option to use Unraid's notification system. Emails and other notification channels can be used through this. If you are using a different operating system, you will need to make your own settings to suit your system.

- **Script Execution/Scheduling**
  - You should be familiar with running bash scripts and know how to run the Restic Rclone Backup script with the required parameters.
  - Users should understand the output of the script and how to interpret the logs generated during the backup process.
  - To automate backup tasks, the execution of the backup job must be scheduled. Under Unraid, the application User-Scripts can be used for this. Otherwise, a cron job can also be created directly.

### **1. Download the repository** ###

- Download the entire repository and place all contained directories and files in a "BackupScripts" directory. Make sure the directory name is spelled correctly. The resulting folder structure is shown below. If the name of the root folder "BackupScripts" is changed, this must be taken into account in the backup jobs under the "home_path" variable and in the Docker commands during setup. Do not change the naming or structure of repository content unless explicitly instructed to do so by the instructions. Place the "BackupScripts" in a suitable location on your system. Since Docker containers need to access the BackupScript directory, the directory used by your Docker container is recommended. Some directories contain a ".gitkeep" file. This is used to ensure that the otherwise empty directory is included in a download. The ".gitkeep" files are otherwise without function and can be deleted.

```
└── BackupScripts
    ├── ActiveLocks
    ├── Config
    │   ├── RcloneConfig
    │   └── ResticConfig
    ├── Executor
    ├── FilterFiles
    ├── Jobs
    ├── Logfiles
    └── SetupInstructions
```
### **2. Setup Restic and Rclone** ###

- In order to use Restic, a repository must be created. The snapshots of your backups are created in the repository. See the Restic [documentation](https://restic.readthedocs.io/en/latest/). You can add all backup jobs to the same repository, creating a separate one for each job. To create a repository follow the instructions from "BackupScripts>SetupInstruction>Create_Repository.txt".

- To use Rclone, a configuration for the remote system must be created. If no remote backups are desired, this can be dispensed with. However, the schedule for Rclone in the backup job must then be set to "never". Rclone supports a variety of cloud providers and transmission protocols. See the Rclone [documentation](https://rclone.org/docs/) for selection and setup. Once you have decided to use remote system you can start the interactive creation process by following the instructions from "BackupScripts>SetupInstruction>Create_Rclone_Config.txt".

### **3. Setup Restic and Rclone** ###

- So that scripts can be executed on your system shell, they must first be made executable. All relevant files are listed in "BackupScripts>SetupInstructions>Make_Executable.txt". Change the path to match the BackupScripts directory on your system. The commands can then be copied into a terminal window and executed. Before doing this, however, make sure that you have the necessary rights and that the changed paths are correct. The execution was successful if you don't get any feedback.

### **4. Setup Notification** ###

- If an error occurs when executing a script, a notification can be sent. This is already prepared for the unraid notification system. To activate this function, the script "BackupScripts>Executor>Notifier.sh" must be opened with an editor. In the "to_system_notification" method, the commented out command can then be activated. The script is designed in such a way that further interfaces for notifications can be added. Customize this to suit your needs. The script must then be placed back in its original position. The script may have to be made executable again.

## Usage<a name="usage"></a>

###  Setting up a backup job ###

Once the setup is complete, any number of backup jobs can be created. To quickly and easily create a backup job, a job template is provided. The BaseJob.sh template can be found under "BackupScripts>Jobs". By creating a copy, the template can be customized to the desired backup job. For this purpose, a number of variables are available that can be used to configure the backup job. Please do not change the names of the variables or the range under them. It is also not necessary to change the files in the executor directory, with the exception of Notifier.sh for setting up custom notification interfaces.

A backup job consists of a total of four sub-processes:
1. **Restic** Backup: Here, the source directory is scanned and a snapshot is added to the repository. Since in some cases Docker containers have to be stopped for this, a corresponding function is implemented. This can be used to stop and restart individual or all active containers for the duration of the backup.
2. **Restic Forget**: Snapshots can be given a shelf life. If this is exceeded, the snapshots in question are removed from the repository. Retention guidelines are available for this purpose. During the "Forget" process, these policies are applied to the snapshots in the repository and removed.
3. **Restic Prune**: A "Forget" only removes the incremental links, but does not delete any data from the repository. This is done by running "Prune". This scans for files that are no longer linked to any existing snapshot and then deletes them.
4. **Rclone Remote Backup**: Rclone is used to transfer the local repository to a remote system. In this process, the selected Rclone configuration is used and the repository is transferred. The script uses the "sync" mode of Rclone. Therefore, files that are no longer present in the local repository are also removed from the remote repository.

The sub-processes "Forget", "Prune" and "Rclone Remote Backup" can be provided with their own schedule. These are independent of the execution schedule of the backup job. If the "weekly" or "mothly" pattern is used, these processes will only be started if the execution of the backup job matches the respective schedule. On the day on which a schedule is active, the sub-process is only executed once and then a lock file is created in the "ActivLocks" directory. As long as this file exists, no further execution of the sub-process will take place on the day of execution. After one day, the old lock files are automatically deleted. If a sub-process is to be executed a second time, the second schedule must be set to "always" or the lock file in question must be deleted manually from the "ActivLocks" directory.

An overview of all the variables available is listed below with descriptions. It is recommended that you read about the variables before using this script. In all other cases, a look at the documentation of restic and rclone will also help.

### Configuration ###

The most important variables to configure are:

- `job_name`: The name of the script or the backup job. Must be unique, as this is used to detect whether the backup job is already running.
- `home_path`: The path to the "BackupScripts" directory containing the script and its utilities.
- `hostname`: The name used to identify your system in the snapshots.
- `source`: The source directory to be backed up. Support for Docker volume propagation! E.G. "/PATH/TO/DATA:rw,slave" 
- `repo`: The path to the backup repository where the backups will be stored. Support for Docker volume propagation! E.G. "/PATH/TO/REPO:rw,slave"
- `password_file`: The file name containing the password for the backup repository.
- `tags`: Tags to be assigned to the snapshots of the backup.
- `filter_file`: Restic allows you to set a filter file. To set it up, see the documentation. 
- `restic_options`: Additional options specific to Restic. See the `restic_options` in the restic documentation.
- `schedule_forget`: Schedule for the execution of the Restic forget process.
- `hourly_for`, `daily_for`, `weekly_for`, `monthly_for`, `yearly_for`: Time periods for keeping snapshots.
- `schedule_prune`: The schedule for removing old snapshots from the repository.
- `handle_docker`: Specifies whether Docker containers should be stopped during the backup.
- `reverse_on_start`: Specifies whether the order of the container list should be reversed on startup.
- `stop_start_remaining_container`: Specifies whether remaining containers should be stopped and started after stopping the containers in the list.
- `container_list`: A list of containers to be stopped in a specific order. The order of the list corresponds to the order of stopping.
- `schedule_rclone`: The schedule for running Rclone.
- `dest_remote`: The destination for Rclone.
- `log_level`: The log level for Rclone.
- `rclone_options`: Additional options specific to Rclone.

### Execution of the script ###

In order to automatically execute the backup defined in the backup job, a schedule must be created. Unraid offers the "User Scripts" plugin for this purpose. This is a convenient way to execute scripts with a cron job. How to set up a cron job via terminal can be found in these instructions [Cron jobs](https://www.freecodecamp.org/news/cron-jobs-in-linux/). The execution of the backup job then takes place at the defined frequency, whereby the "backup process" is implemented with every execution and the other processes of the schedules defined in the script.

### Mounting the repository ###

Restic allows you to make the contents of a backup repository accessible as a regular file system on your computer or server. This allows you to access individual files or directories within the repository without having to restore the entire backup. This process is called mounting. How to mount a repository can be found in the instructions from "BackupScripts>SetupInstuctions>Mount_Repository". How to use a mounted repository is described in the documentation of restic.




## Final Note<a name="final-note"></a>

I hope these scripts help you to simplify your backup process. The intention for creating these scripts and writing this guide came about mainly because it took me a relatively long time to use Restic and Rclone over docker containers. Unfortunately, there were no suitable solutions or instructions for me. Therefore, I hope that this will make the way to your backups a little easier for you.

If you have any questions, comments or errors, please let me know.

With this in mind, I wish you happy backups!



## License<a name="license"></a>

MIT License

Copyright (c) 2023 David Krumm

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
