# BackupScript with Restic and Rclone

## Introduction

Welcome to the BackupScripts Repository! This small private project aims to create fast, easy and reliable backups. After setup, all you need to do for this is to customize a template for the desired backup job. The powerful tools Restic and Rclone are used for the backup process. Since the official Docker containers of Restic and Rclone are installed automatically, no additional installation is required. All that is needed is a Unix system (Linux or macOS) on which Docker containers can be run.

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

The BackupScript project is a set of bash scripts designed to manage local and remote backups with the Restic and Rclone tools. Its main purpose is to provide a flexible and customisable solution for performing incremental backups, rotating snapshots and moving backups to a remote system.

The script is structured with a job template. By customising this template and defining values such as the source directory for the backup, the path to the backup repository, the password file for the repository us, multiple backup jobs can be created easily and flexibly. Since the official Docker containers of the respective projects are used to run Rclone and Restic, no direct installation on the system is necessary.

The script offers functions for handling Docker containers during the backup, so that containers are stopped in a defined order and then restarted. By scheduling the created backup jobs with cron jobs or similar solutions, the entire backup process can be automated.

## Installation<a name="installation"></a>

To install and set up the project, please follow the steps below:

### Requirements ###

- **Operating System**
  - The script is designed to run on a Unix-like operating system such as Linux or macOS.

- **Dependencies**
  - Docker: The host system should have Docker installed and properly configured to run containers.
  - Restic and Rclone: The official Docker images [Restic](https://hub.docker.com/r/restic/restic) and [Rclone](https://hub.docker.com/r/rclone/rclone) are used for execution and installed automatically. Ensure that the system has access to the Internet. Otherwise, the images must be deployed locally.

- **Setup/Job Configuration**
  - Read the instructions to ensure the correct setup and function of backup scripts.
  - It is helpful if you inform yourself about the basic functions of Restic and Rclone in order to gain a better understanding of the function and structure of backup scripts.
  - Restic and Rclone are command line programs. Detailed instructions are provided for their use. However, there is no graphical user interface.
  - As Docker containers are used, you should have basic knowledge of working with Docker containers.

- **Access and Permissions**
  - You should have sufficient access rights on the system to run the script and access the required directories, files, and Docker resources.

- **Notification Setup**
  - The script offers the option of sending notifications. This is already prepared for Unraid. Other output sources (e.g. e-mail) must be implemented yourself. 

- **Script Execution/Scheduling**
  - The use of backup scripts requires the execution of bash scripts. Detailed instructions are provided for this.
  - To automate backup tasks, the execution of the backup job must be scheduled. Under Unraid, the "User Scripts" application can be used for this purpose. Alternatively, a cron job can be created directly under Linux systems. Detailed instructions are provided for this.

### **1. Download the repository** ###
- Download the entire repository and place all the directories and files it contains in a new directory named "BackupScript". Pay attention to the correct spelling of the directory name. The resulting folder structure is shown below. If the name of the root directory "BackupScript" is changed, this must be taken into account in the backup jobs under the variable "path_to_BackupScript" and in the Docker commands during setup. Do not change the naming or structure of the repository content unless you are explicitly asked to do so in the instructions. Place the filled "BackupScript" directory in a suitable location of your choice on your system.

```
└── BackupScript
    ├── Config
    │   ├── DockerConfig
    │   ├── FilterConfig
    │   ├── RcloneConfig
    │   └── RepositoryPassword
    ├── Executor
    ├── Jobs
    └── SetupInstructions
```

### **2. Setup backup repository** ###
- A repository must be created before use. This is where the incremental backups are stored. You can add all backup jobs to the same repository or create a separate repository for each job. Restic [Documentation] (https://restic.readthedocs.io/en/latest/) is used to create the backups. To create a repository, follow the instructions in "BackupScript>SetupInstruction>Create_Repository.txt".

### **3. (Optional) Setup remote system** ###
- To increase the security of the backups, the repository can be transferred to a remote system or cloud. Rclone [Documentation] (https://rclone.org/docs/) is used for this purpose. Rclone offers a variety of options for connecting to a remote system or cloud. Before using a new connection for the first time, it must be configured according to the Rclone documentation [Configure] (https://rclone.org/docs/#configure). If no remote backups are required, this step can be skipped. However, the schedule for Rclone in the backup job must then be set to "never". If you have decided to use a remote system, you can start the interactive setup process by following the instructions in "BackupScript>SetupInstruction>Create_Rclone_Config.txt". All information required for the setup process is provided by the Rclone documentation. Adding new connections or changing existing ones is possible at any time.

### **4. Setup backup job** ###
- New backup jobs are created by configuring a job. A pre-filled template is provided for this purpose. Create a copy of the "JobTemplate" file in the "BackupScript>Jobs" directory and give it a unique name (avoid using spaces and underscores). A description of the configuration of new jobs is given in the section [Usage](#usage). By copying the template, any number of jobs with different configurations can be created.

### **4. (Optional) Setup notification** ###
- If important events occur during the execution of a script, a notification can be sent. This is already prepared for the unraid notification system. To activate this function, the script "BackupScript>Executor>Notifier" must be opened with an editor. Activation is done by removing the "#" at the beginning of line 100. "Notifier" is designed so that further interfaces for notifications can be added as functions. Implement the interfaces required for your needs and add the methods in the desired "Output Channel".

## Usage<a name="usage"></a>

###  Setting up a backup job ###

Once the setup is complete, any number of backup jobs can be created. To quickly and easily create a backup job, a job template is provided. The file "JobTemplate" can be found under "BackupScript>Jobs". By creating a copy, the template can be customized to the desired backup job. For this purpose, a number of variables are available that can be used to configure the backup job. Please do not change the names of the variables or the range under them. It is also not necessary to change the files in the executor directory, with the exception of "Notifier" for setting up custom notification interfaces.

A backup job consists of a total of four sub-processes:
1. **Backup (Restic)** In this step, the source directory is scanned and a new snapshot is added to the repository. As in some cases Docker containers have to be stopped for a backup (e.g. when backing up a database), they can be stopped during the backup using a configuration file and then restarted.
2. **Forget (Restic)**: Snapshots can be given a shelf life. If this is exceeded, the snapshots in question are removed from the repository. Retention guidelines are available for this purpose. During the "Forget" process, these policies are applied to the snapshots in the repository and removed.
3. **Prune (Restic)**: When "forgetting", only the incremental links are removed, but no data is deleted from the repository. This is achieved by running "Prune". This searches for files that are not linked to any existing snapshot and can therefore be deleted.
4. **Remote Copy (Rclone)**: Rclone is used to transfer the local repository to a remote system. In this process, the selected Rclone configuration is used and the repository is transferred. The script uses the "sync" mode of Rclone. Therefore, files that are no longer present in the local repository are also removed from the remote repository.

The sub-processes "Backup", "Forget", "Prune" and "Remote Copy" have their own schedule. This is independent of the job's execution schedule. Regardless of how often the job is executed, the respective sub-process is only executed if this is provided for by the respective schedule. Sub-processes can be executed "never", "always", on certain days of the week "weekly" or on certain days of the month "monthly". If the "weekly" or "monthly" pattern is used, the sub-process is only executed once on the day in question. This makes it possible, for example, to create a local backup every 5 minutes by executing the job at this interval and setting the schedule for "Backup" to "always", but only copying to the remote system on certain days using a "weekly" schedule. To prevent re-execution, "Lock files" are created under the path "BackupScript > ConditionMarks" with the designation of the job name and the sub-process. If a sub-process is to be executed a second time, the schedule can be set to "always" for a short time or the relevant lock file must be deleted manually from the "ConditionMarks" directory. Obsolete lock files are deleted automatically

An overview of all the variables available is listed below with descriptions. It is recommended that you read about the variables before using this script. In all other cases, a look at the documentation of restic and rclone will also help.

### Job Configuration ###

The most important variables to configure are:

- `unique_job_name`: The name of the script or the backup job. Must be unique, as this is used to detect whether the backup job is already running.
- `path_to_BackupScript`: The path to the "BackupScript" directory containing the script and its utilities.
- `system_id_name`: The name used to identify your system in the snapshots.
- `schedule_update_Restic_and_Rclone`:
- `notify_after_completion`:
- `schedule_backup`:
- `path_to_the_directory_to_be_backed_up`: The source directory to be backed up. Support for [Docker volume propagation](https://docs.docker.com/storage/bind-mounts/)! E.G. "/PATH/TO/DATA:rw,slave".  
- `path_to_restic_repository`: The path to the backup repository where the backups will be stored. Support for [Docker volume propagation](https://docs.docker.com/storage/bind-mounts/)! E.G. "/PATH/TO/REPO:rw,slave"
- `name_restic_password_file`: The file name containing the password for the backup repository.
- `restig_backup_tags`: Tags to be assigned to the snapshots of the backup.
- `name_restic_filter_file`: Restic allows you to set a filter file. To set it up, see the documentation. 
- `restic_options`: Additional options specific to Restic. See the `restic_options` in the restic documentation.
- `name_docker_config_file`: 
- `reverse_docker_start_sequence`: 
- `schedule_forget`: Schedule for the execution of the Restic forget process.
- `keep_*_for`: Time periods for keeping snapshots.
- `schedule_prune`: The schedule for removing old snapshots from the repository.
- `rclone_remote_path`: The schedule for running Rclone.
- `name_rclone_filter_file`: The destination for Rclone.
- `rclone_options`: Additional options specific to Rclone.

### Execution of the script ###

In order to automatically execute the backup defined in the backup job, a schedule must be created. Unraid offers the "User Scripts" plugin for this purpose. This is a convenient way to execute scripts with a cron job. How to set up a cron job via terminal can be found in these instructions [Cron jobs](https://www.freecodecamp.org/news/cron-jobs-in-linux/). The execution of the backup job then takes place at the defined frequency, whereby the "backup process" is implemented with every execution and the other processes of the schedules defined in the script.

### Mounting the repository ###

Restic allows you to make the contents of a backup repository accessible as a regular file system on your computer or server. This allows you to access individual files or directories within the repository without having to restore the entire backup. This process is called mounting. How to mount a repository can be found in the instructions from "BackupScript>SetupInstuctions>Mount_Repository". How to use a mounted repository is described in the documentation of restic.




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
