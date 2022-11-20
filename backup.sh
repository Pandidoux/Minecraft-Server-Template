#!/bin/bash


# ____________________________________________________________
# Server folder name
server_folder="server"
# Items to backup
declare -a backup_files_or_folders=(
    "world"
    "world_nether"
    "world_the_end"
    ".console_history"
    "banned-ips.json"
    "banned-players.json"
    "bukkit.yml"
    "commands.yml"
    "eula.txt"
    "help.yml"
    "ops.json"
    "permissions.yml"
    "server.properties"
    "server-icon.png"
    "setup_server.sh"
    "spigot.yml"
    "start.bat"
    "start.sh"
    "usercache.json"
    "version_history.json"
    "wepif.yml"
    "whitelist.json"
    "config"
    "logs"
    "plugin"
)

if [[ "$OSTYPE" == "linux-gnu"* ]]; then # Linux
    # Number of backups to keep, older will be deleted. (0 to disable)
    nbBackup=10
    # Backup directory destination
    backup_directory="/path/to/backups"
    # 7Zip executable (ex: 7z.exe)
    compression_executable="7z"
    # Compression parameters
    compression_params="a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on -r -bsp2"
elif [[ "$OSTYPE" == "msys" ]]; then # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    # Number of backups to keep, older will be deleted. (0 to disable)
    nbBackup=5
    # Backup directory destination
    backup_directory="backups"
    # 7Zip executable (ex: 7z.exe)
    compression_executable="\"/c/Program Files/7-Zip/7z.exe\""
    # Compression parameters
    compression_params="a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=1024m -ms=on -r -bsp2"
elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OSX
    # Number of backups to keep, older will be deleted. (0 to disable)
    nbBackup=5
    # Backup directory destination
    backup_directory=""
    # 7Zip executable (ex: 7z.exe)
    compression_executable=""
    # Compression parameters
    compression_params=""
elif [[ "$OSTYPE" == "cygwin" ]]; then # POSIX compatibility layer and Linux environment emulation for Windows
    # Number of backups to keep, older will be deleted. (0 to disable)
    nbBackup=5
    # Backup directory destination
    backup_directory=""
    # 7Zip executable (ex: 7z.exe)
    compression_executable=""
    # Compression parameters
    compression_params=""
else # Unknown.
    # Number of backups to keep, older will be deleted. (0 to disable)
    nbBackup=5
    # Backup directory destination
    backup_directory=""
    # 7Zip executable (ex: 7z.exe)
    compression_executable=""
    # Compression parameters
    compression_params=""
fi
# ____________________________________________________________




exit_code=1
plugins_backup=0
if [[ ! -z "$1" ]]; then
    # backup from EssentialsX plugin while server is still running
    if [[ "$1" = "--essentials" ]]; then
        plugins_backup=1
    fi
fi


script_execution_path=$(cd "$(dirname "$0")" && pwd)
absolute_server_directory="$script_execution_path/$server_folder"
# If backup directory doesn't exist.
if [ -d $backup_directory ]; then
    absolute_backup_directory=$(cd "$backup_directory" && pwd)
else
    absolute_backup_directory="$script_execution_path/$backup_directory"
fi


# If directory doesn't exist.
if [ ! -d $absolute_backup_directory ]; then
    echo "Create directory: $absolute_backup_directory"
    mkdir -p $absolute_backup_directory
fi


# Loop through all backup_files_or_folders items
sources_list=""
for bkp_item in "${backup_files_or_folders[@]}"
do
    source="\"$absolute_server_directory/$bkp_item\""
    # If item exist
    if [ -d "$source" ] || [ ! -f "$source" ]; then
        # Add item to sources_list
        sources_list="$sources_list $source"
    else
        echo "WARN: Item not found $source"
    fi
done


dateTime=$(date +"%Y-%m-%d_%H-%M-%S")
archive_name="backup_$dateTime.7z"
command="$compression_executable $compression_params \"$absolute_backup_directory/$archive_name\" $sources_list"
# Execute compression command
if [ $plugins_backup -eq 0 ]; then
    echo "$command"
fi
eval "$command"
exit_code=$?
if [ $exit_code -ne 0 ]; then
    exit $exit_code
fi

# Keep only N most recents backups
if [ $nbBackup -ne 0 ]; then
    echo "Delete backups in $absolute_backup_directory/ exept the $nbBackup most recent"
    (ls "$absolute_backup_directory/" -tp | grep '^backup_' | tail -n +$(($nbBackup + 1)) | xargs -I {} rm -- "$absolute_backup_directory/{}")
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        exit $exit_code
    fi
fi


# Print items backup in directory
if [ $plugins_backup -eq 1 ]; then
    echo "Files in backup directory :"
    (ls -sh "$absolute_backup_directory/" | xargs -I {} echo {})
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        exit $exit_code
    fi
fi


if [ $plugins_backup -eq 0 ]; then
    sleep 5
    read -p "Press Enter to continue"
fi


exit $exit_code
