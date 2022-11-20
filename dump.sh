#!/bin/bash

# ____________________________________________________________
# Server folder name
source_folder="server"
# Backup directory destination
backup_directory="backups"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then # Linux
    # Backup directory destination
    backup_directory="/path/to/backups"
    # 7Zip executable (ex: 7z.exe)
    compression_executable="7z"
    # Compression parameters
    compression_params="a -t7z -m0=lzma2 -mx=7 -mfb=64 -md=1024m -ms=on -r -bsp2"
elif [[ "$OSTYPE" == "msys" ]]; then # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    # Backup directory destination
    backup_directory="backups"
    # 7Zip executable (ex: 7z.exe)
    compression_executable="\"/c/Program Files/7-Zip/7z.exe\""
    # Compression parameters
    compression_params="a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=1024m -ms=on -r -bsp2"
elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OSX
    # Backup directory destination
    backup_directory=""
    # 7Zip executable (ex: 7z.exe)
    compression_executable=""
    # Compression parameters
    compression_params=""
elif [[ "$OSTYPE" == "cygwin" ]]; then # POSIX compatibility layer and Linux environment emulation for Windows
    # Backup directory destination
    backup_directory=""
    # 7Zip executable (ex: 7z.exe)
    compression_executable=""
    # Compression parameters
    compression_params=""
else # Unknown.
    # Backup directory destination
    backup_directory=""
    # 7Zip executable (ex: 7z.exe)
    compression_executable=""
    # Compression parameters
    compression_params=""
fi
# ____________________________________________________________

script_execution_path=$(cd "$(dirname "$0")" && pwd)
absolute_server_directory="$script_execution_path/$source_folder"
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


if [ ! -d "$absolute_server_directory" ]; then
    echo "ERROR: Folder not found $absolute_server_directory"
fi


dateTime=$(date +"%Y-%m-%d_%H-%M-%S")
archive_name="dump_$dateTime.7z"
command="$compression_executable $compression_params \"$absolute_backup_directory/$archive_name\" \"$absolute_server_directory\""


# Execute command
echo "$command"
eval "$command"


sleep 5
read -p "Press Enter to continue"