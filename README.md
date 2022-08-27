# Minecraft-Server-Template
A simple template directory for Minecraft servers

# What you got ?
- setup_server.sh -> Setup your server (build, auto accept eula, first start)
- start.sh -> Start / Restart your server
- backup.sh -> Backup specified files and folder of your server
- dump.sh -> Backup the entier server folder


# Setup scripts for your server
## Download
1) Open git bash in your MC servers directory
2) Clone this repo: `git clone https://github.com/Pandidoux/Minecraft-Server-Template.git`
3) Rename the folder `Minecraft-Server-Template` with the name you want
4) Add your servers jar files

## Replace some string in setup_server.sh :
- Server installer JAR file
- Server JAR file
- Path to Java

## Replace some string in start.sh :
- Server JAR file
- Path to Java
- Java arguments
- Server JAR arguments

## Replace some string in backup.sh :
- Items to backup
- 7Zip executable (ex: 7z.exe)
- Compression parameters

## Replace some string in dump.sh :
- 7Zip executable (ex: 7z.exe)
- Compression parameters