#!/bin/bash


# Source folder
source_folder="server"
# Backup directory destination
backup_directory="backups"
# 7Zip executable (ex: 7z.exe)
compression_executable="/c/Program Files/7-Zip/7z.exe"
# Compression parameters
compression_params="a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=1024m -ms=on -r -bsp2"


# If directory doesn't exist.
if [ ! -d $backup_directory ]; then
    echo "Create directory: $backup_directory"
    mkdir -p $backup_directory
fi


if [ ! -d "$source_folder" ]; then
    echo "ERROR: Folder not found $source_folder"
fi


dateTime=$(date +"%Y-%m-%d_%H-%M-%S")
archive_name="dump_$dateTime.7z"
command="\"$compression_executable\" $compression_params \"$backup_directory/$archive_name\" \"$source_folder\""


# Execute command
echo "$command"
eval "$command"


sleep 5
read -p "Press Enter to continue"