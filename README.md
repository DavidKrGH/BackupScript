# BackupScripts with Restic and Rclone

# Project Documentation

## Introduction

Welcome to the Backup Scripts Repository! This small private project aims to provide a set of shell scripts to facilitate the backup process of a folder structure using two powerful tools: Restic and Rclone.

[Restic](https://restic.net/) is an open source backup utility to protect your data by safely storing and restoring incremental backups. It is easy to use, efficient and reliable and offers a straightforward and flexible solution for backing up and restoring data. With Restic, you can manage your backup process, encrypt your data, store it and ensure the security and accessibility of your important files.

[Rclone](https://rclone.org/) is a versatile command line programme that allows you to synchronise files and directories between different storage locations. Its main purpose is to provide a unified interface for managing and transferring data between different storage platforms such as Google Drive, Dropbox, Amazon S3 or your own remote server. Rclone provides the ability to copy, move and synchronise files, as well as perform advanced operations such as encryption, deduplication and bandwidth control, making it a powerful tool for managing cloud storage.

The combination of Restic and Rclone provides a flexible and robust solution for performing backups that ensures the security and integrity of your data. The scripts provided in this repository simplify the configuration and execution of backup operations and make it easy for you to set up and maintain a reliable backup system.

Only basic command line knowledge is required for use and installation. Restic and Rclone are installed exclusively via the official Docker containers of the respective projects. The automation of the individually created backup jobs can be realised via cron jobs or similar. The scripts are not connected to Restic or Rclone. No liability is assumed for the use or loss of data.

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
4. [License](#license)

## Project Description<a name="project-description"></a>

The BackupScripts project is a set of bash scripts designed to manage local and remote backups with the Restic and Rclone tools. Its main purpose is to provide a flexible and customisable solution for performing incremental backups, rotating snapshots and moving backups to a remote system.

The script is structured with a job template. By customising this template and defining values such as the source directory for the backup, the path to the backup repository, the password file for the repository us, multiple backup jobs can be created easily and flexibly. Since the official Docker containers of the respective projects are used to run Rclone and Restic, no direct installation on the system is necessary.

The script offers functions for handling Docker containers during the backup, so that containers are stopped in a defined order and then restarted. By scheduling the created backup jobs with cron jobs or similar solutions, the entire backup process can be automated.

## Installation<a name="installation"></a>

To install and set up the project, please follow the steps below:

1. **Requirements**: Ensure you have the following prerequisites installed on your system:

Operating system: The script is designed to run on a Unix-like operating system such as Linux or macOS.

Dependencies:
a. Docker: The host system should have Docker installed and properly configured to run containers.
b. Restic and Rclone: The Docker images Restic and Rclone are required to run the script. If the images are not available locally, they will be downloaded automatically. Make sure the system has access to the internet or provide the images locally.

Setup/job configuration:
a. You should know how to edit the job template included in the script to define the required values for your backup tasks. These values include the job name, source directory, repository path, password file, tags and other options specific to Restic and Rclone.
b. For proper backup job setup, you should be familiar with the function of Restic and Rclone. Please refer to the documentation of the programs.
c. Since Restic and Rclone are command line programs, you should have basic knowledge of using the terminal.
d. Since Docker containers are used, you should have basic knowledge of using Docker containers. 

Access and permissions:
a. You should have sufficient access rights on the system to run the script and access the required directories, files and Docker resources.
b. If using Docker containers, you should have the appropriate permissions to interact with Docker, run containers and manage container networks.

Notification setup:
a. The script provides the option to use Unraid's notification system. Emails and other notification channels can be used through this. If you are using a different operating system, you will need to make your own settings to suit your system.

Script execution/scheduling:
a. You should be familiar with running bash scripts and know how to run the Restic Rclone Backup script with the required parameters.
b. Users should understand the output of the script and how to interpret the logs generated during the backup process.
c. To automate backup tasks, the execution of the backup job must be scheduled. Under Unraid, the application User-Scripts can be used for this. Otherwise, a cron job can also be created directly.

2. **Clone the repository**: Use the following command to clone the repository to your local machine:

https://github.com/[username]/[repository].git

3. **Dependencies**: Install the project dependencies by running the following command:

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



4. **Configuration**: If there are any additional configuration steps required, outline them here.

## Usage<a name="usage"></a>

Provide instructions on how to use the project. Include examples, code snippets, or detailed explanations to guide users through different functionalities. Describe any available options, flags, or parameters that can be used.

[Include any relevant information regarding project usage, such as commands, APIs, or user interfaces.]


## License<a name="license"></a>

MIT License

Copyright (c) 2023 DavidKrGH

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

## Additional Resources

Provide any additional resources that can assist users in understanding or working with the project, such as:

- Link to the project's website or documentation
- Related articles or tutorials
- Community forums or support channels

## Conclusion

This documentation should provide you with the necessary information to get started with BackupScripts. If you have any questions or need further assistance, feel free to reach out to the project maintainers or refer to the provided additional resources. Happy coding!
