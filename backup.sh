#!/bin/bash


# ____________________________________________________________
# Source folder
source_folder="server"
# Items to backup
declare -a backup_files_or_folders=(
    "world"
    "logs"
    "eula.txt"
    "server.properties"
    "start.sh"
	"start.bat"
	"banned-ips.json"
	"banned-players.json"
	"ops.json"
	"options.txt"
	"server-icon.png"
	"whitelist.json"
	"setup_server.sh"
)
# Backup directory destination
backup_directory="backups"
# 7Zip executable (ex: 7z.exe)
compression_executable="/c/Program Files/7-Zip/7z.exe"
# Compression parameters
compression_params="a -t7z -m0=lzma2 -mx=7 -mfb=64 -md=1024m -ms=on -r -bsp2"
# ____________________________________________________________


# If directory doesn't exist.
if [ ! -d $backup_directory ]; then
    echo "Create directory: $backup_directory"
    mkdir -p $backup_directory
fi


# Loop through all backup_files_or_folders items
sources_list=""
for bkp_item in "${backup_files_or_folders[@]}"
do
    source="\"$source_folder/$bkp_item\""
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
command="\"$compression_executable\" $compression_params \"$backup_directory/$archive_name\" $sources_list"


# Execute command
echo "$command"
eval "$command"

sleep 5
read -p "Press Enter to continue"