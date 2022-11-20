# Minecraft-Server-Template
A simple template directory for Minecraft servers (subject to changes)

# What you got ?
## setup_server.sh
- Setup your server (build, auto accept eula, run a first start)
## start.sh
- Start your server.
- Can restart your server in case of shutdown.
- Restart your server when server crash (based on server.jar exit code).
- Detect boot-loop crash to stop the script automaticaly (based on recurent amount of crashs within a certain time window).
- Different parameters to run on different OS / environnement.
## backup.sh
- Backup specified files and folder of your server
- Handle EssentialsX `/backup` command (dont pause the script) if `--essentials` parameter is specified for the command in the plugin confuguration
- Different parameters to run on different OS / environnement.
## dump.sh
- Backup the entier server folder
- Different parameters to run on different OS / environnement.


# How to setup the scripts for your server
## Download
1) Open git bash in your MC servers directory
2) Clone this repo: `git clone https://github.com/Pandidoux/Minecraft-Server-Template.git`
3) Rename the folder `Minecraft-Server-Template` with the name you want for your server
4) Add your servers jar files

## Replace some variable parameters in setup_server.sh
(if you want automatic installation)
- Java (path/command)
`javaExecutable="java"`
- Java arguments
`javaArguments="-jar -Xms1G -Xmx2G"`
- Server installer JAR file
`serverInstallerJar="server-installer.jar"`
- Server JAR file
`serverJar="server.jar"`
- Server JAR arguments
`jarArguments="nogui"`

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