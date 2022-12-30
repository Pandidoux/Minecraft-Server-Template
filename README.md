# Minecraft-Server-Template
A simple template directory for Minecraft servers

Code repository subject to changes, download the [releases](https://github.com/Pandidoux/Minecraft-Server-Template/releases) section for stable versions.


# What each scripts do ?
## start.sh
- Start your server.
- Can restart your server in case of shutdown or crash.
- Restart your server when server crash (based on server.jar exit code).
- Detect boot-loop crash to stop the script automaticaly (based on recurent amount of crashs within a defined time window).
- Different parameters to run on multiple OS / environnement.
## backup.sh
- Backup specified files and folder of your server
- Handle EssentialsX `/backup` command (dont pause the script) if `--essentials` parameter is specified for the command in the plugin confuguration
- Different parameters to run on different OS / environnement.
## dump.sh
- Backup the entier server folder
- Different parameters to run on different OS / environnement.


# Installation
1) Install `Git` to run `.sh` scripts
2) Create your server folder "`server-name`" where you want.
3) Download the latest [releases](https://github.com/Pandidoux/Minecraft-Server-Template/releases) of Minecraft-Server-Template
4) Extract the archive content, you will find a folder named `Minecraft-Server-Template-X.X.X`
5) move all files in the `Minecraft-Server-Template-X.X.X` folder in your `server-name` folder
6) Add your server.jar file in the `server-name/server` folder

# Configuration
## Replace some variable parameters in start.sh
(if you want to start your server)
- Server JAR file (accept "server-*.jar" patern lastest version will be choosen) :
`serverJar="server-1.19.2-*.jar"`
- Java (path/command):
`javaExecutable="java"`
- Java arguments :
`javaArguments="-jar -Xms1G -Xmx6G"`
- Server JAR arguments :
`jarArguments="nogui"`
- Reboot server when stoped or crash :
`looping=true`
- Wait X seconds before server start :
`timer=10`
- Max restart try after a crash during or just after starting the server (prevent infinite boot-loop) :
`maxBootLoopCrash=5`
- Time after considering the server is started without any crash (in seconds) :
`crashLoopMinTimer=300`

## Replace some variable parameters in backup.sh
(if you want to use this backup script)
- Server folder name :
`server_folder="server"`
- Items to backup :
`backup_files_or_folders=( files/folders... )`
- Number of backups to keep, older will be deleted. (0 to  :disable)
`nbBackup=10`
- Backup directory destination :
`backup_directory="/path/to/backups"`
- 7Zip executable (ex: 7z.exe/7z) :
`compression_executable="7z"`
- Compression parameters :
`compression_params="a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on -r -bsp2"`


## Replace some variable parameters in dump.sh
(if you want to backup your entire server folder)
- Server folder name
`source_folder="server"`
- Backup directory destination
`backup_directory="backups"`
- Backup directory destination
`backup_directory="/path/to/backups"`
- 7Zip executable (ex: 7z.exe)
`compression_executable="7z"`
- Compression parameters
`compression_params="a -t7z -m0=lzma2 -mx=7 -mfb=64 -md=1024m -ms=on -r -bsp2"`

## Replace server-icon.png with yours
(or delete/keep it)