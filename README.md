<div align="center">

# Minecraft-Server-Template

## A simple template directory for Minecraft servers.

![MINECRAFT](https://img.shields.io/badge/Server%20Tools-Minecraft-brightgreen?style=for-the-badge&labelColor=444)
![RELEASE](https://img.shields.io/github/v/release/Pandidoux/Minecraft-Server-Template?color=orange&display_name=tag&style=for-the-badge)

![Bash](https://img.shields.io/badge/Bash-v4.4%5E-brightgreen?logo=GNU%20bash)
![Linux](https://img.shields.io/badge/-Linux-grey?style=flat&logo=linux)
![WINDOWS](https://img.shields.io/badge/-Windows-blue?style=flat&logo=windows)
![OSX](https://img.shields.io/badge/-OSX-black?style=flat&logo=apple)

![FILECOUNT](https://img.shields.io/github/directory-file-count/Pandidoux/Minecraft-Server-Template?color=yellow)
![REPOSIZE](https://img.shields.io/github/repo-size/Pandidoux/Minecraft-Server-Template?color=yellow)
![CODELINES](https://img.shields.io/tokei/lines/github/Pandidoux/Minecraft-Server-Template?color=yellow)
![STARS](https://img.shields.io/github/stars/Pandidoux?color=yellow)

![LASTCOMMMIT](https://img.shields.io/github/last-commit/Pandidoux/Minecraft-Server-Template?color=green&style=plastic)
![GitHub Release Date](https://img.shields.io/github/release-date/Pandidoux/Minecraft-Server-Template?style=plastic)
![LICENCE](https://img.shields.io/github/license/Pandidoux/Minecraft-Server-Template?color=green&style=plastic)

### Download the [latest releases](https://github.com/Pandidoux/Minecraft-Server-Template/releases) for stable versions.

</div>

--------------------------------------------------

# Description
## start.sh
- Start your Minecraft server.
- Auto-restart your server in case of shutdown.
- Restart your server when server crash (based on server.jar exit code).
- Detect crash-loop to stop the script automaticaly (based on recurent amount of crashs within a defined time window).
## backup.sh
- Backup only specified files and folder of your server.
- Handle EssentialsX `/backup` command if `--essentials` parameter is specified for the command in the plugin confuguration.
- Keep only X backups in your folder.
- Send your backup on a remote directory (use `rsync` is available, else `cp`).
- Keep only X backups in your remote folder.
## dump.sh
- Backup the entier server folder.
- Keep only X backups in your folder.
- Send your backup on a remote directory (use `rsync` is available, else `cp`).
- Keep only X backups in your remote folder.

--------------------------------------------------

# Installation
1) Install `Git` for your OS to run `.sh` scripts
2) Create your server folder "`server-name`" where you want.
3) Download the [latest releases](https://github.com/Pandidoux/Minecraft-Server-Template/releases) of Minecraft-Server-Template
4) Extract the archive content, you will find a folder named `Minecraft-Server-Template-X.X.X`
5) Move all files inside the `Minecraft-Server-Template-X.X.X` folder to your `server-name` folder
6) Add your server.jar file inside the `server-name/server` folder

--------------------------------------------------

# Configuration
Edit the `config.yml` file. All scripts use this config file.

Each section correspond to the configuration for one specific OS.

You can setup multiple environement.

Each settings name begin with the operating system name "OSNAME_".


## General
| Setting   | Type    | Description                      |
|-----------|:-------:|----------------------------------|
| USE_COLOR | boolean | Use colors in the console output |

--------------------------------------------------

## start.sh
| Setting              | Type    | Description                                                                    |
|----------------------|:-------:|--------------------------------------------------------------------------------|
| SERVER_FOLDER_PATH   | string  | Path to the server folder                                                      |
| JAVA_EXECUTABLE      | string  | Command or path to execute java                                                |
| JAVA_ARGUMENTS       | string  | Java argument for server the server execution                                  |
| SERVER_JAR           | string  | Server JAR file (accept "server-*.jar" patern lastest version will be choosen) |
| SERVER_JAR_ARGUMENTS | string  | Arguments for the server (ex: nogui)                                           |
| BOOT_TIMER           | integer | Time in seconds to wait before server starting                                 |
| REBOOT_SERVER        | boolean | Should the server restart after a crash or shutdown ?                          |
| BOOTLOOP_MAX_CRASH   | integer | Maximum restart try after a crash, if a bootloop is detected stop the script   |
| BOOTLOOP_RESET_TIMER | integer | Time in seconds after a successful start to reset the bootloop prevention      |

--------------------------------------------------

## backup.sh
| Setting                    | Type    | Description                                                                                    |
|----------------------------|:-------:|------------------------------------------------------------------------------------------------|
| BACKUPS_EXECUTABLE         | string  | Command / path of the backup executable (ex: 7zip, tar...)                                     |
| BACKUPS_ARGUMENTS          | string  | Arguments for the backup executable                                                            |
| BACKUPS_DIRECTORY          | string  | Directory to use for the backups files                                                         |
| BACKUPS_NAME               | string  | Name prefix of the backup (inserted before the date)                                           |
| BACKUPS_EXTENTION          | string  | File extention of the backup (inserted after the date)                                         |
| BACKUPS_ITEMS              | array   | List of file / folder to include in the backup (Write all items of the array on the same line) |
| BACKUPS_MAX                | integer | Maximum number of backups stored localy                                                        |
| BACKUPS_REMOTE_ENABLE      | boolean | Enable or disable backups upload                                                               |
| BACKUPS_DIRECTORY_REMOTE   | string  | Directory to use for the remote backups files                                                  |
| BACKUPS_MAX_REMOTE         | integer | Maximum number of backups stored remotely                                                      |
| BACKUPS_PAUSE_AFTER_FINISH | boolean | Pause script after complete instead of exit                                                    |

--------------------------------------------------

## dump.sh
| Setting                  | Type    | Description                                                      |
|--------------------------|:-------:|------------------------------------------------------------------|
| DUMPS_EXECUTABLE         | string  | Command / path of the server dumps executable (ex: 7zip, tar...) |
| DUMPS_ARGUMENTS          | string  | Arguments for the server dumps executable                        |
| DUMPS_DIRECTORY          | string  | Directory to use for the server dumps files                      |
| DUMPS_MAX                | integer | Maximum number of dumps stored localy                            |
| DUMPS_NAME               | string  | Name prefix of the dump (inserted before the date)               |
| DUMPS_EXTENTION          | string  | File extention of the dump (inserted after the date)             |
| DUMPS_MAX                | integer | Maximum number of dumps stored localy                            |
| DUMPS_REMOTE_ENABLE      | boolean | Enable or disable dumps upload                                   |
| DUMPS_DIRECTORY_REMOTE   | string  | Directory to use for the remote dumps files                      |
| DUMPS_MAX_REMOTE         | integer | Maximum number of dumps stored remotely                          |
| DUMPS_PAUSE_AFTER_FINISH | boolean | Pause script after complete instead of exit                      |

--------------------------------------------------
Please leave a star on the project if you like it.