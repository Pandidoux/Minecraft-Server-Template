#!/bin/bash

# ____________________________________________________________
source_folder="server" # Source folder
backup_directory="backups" # Backup directory destination

if [[ "$OSTYPE" == "linux-gnu"* ]]; then # Linux
    backup_directory="/path/to/backups" # Backup directory destination
    compression_executable="tar" # compression executable (ex: 7z.exe, tar)
    compression_params="-czf" # Compression parameters
elif [[ "$OSTYPE" == "msys" ]]; then # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    backup_directory="backups" # Backup directory destination
    compression_executable="\"/c/Program Files/7-Zip/7z.exe\"" # compression executable (ex: 7z.exe, tar)
    compression_params="a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=1024m -ms=on -r -bsp2" # Compression parameters
elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OSX
    backup_directory="" # Backup directory destination
    compression_executable="" # compression executable (ex: 7z.exe, tar)
    compression_params="" # Compression parameters
elif [[ "$OSTYPE" == "cygwin" ]]; then # POSIX compatibility layer and Linux environment emulation for Windows
    backup_directory="" # Backup directory destination
    compression_executable="" # compression executable (ex: 7z.exe, tar)
    compression_params="" # Compression parameters
else # Unknown.
    backup_directory="" # Backup directory destination
    compression_executable="" # compression executable (ex: 7z.exe, tar)
    compression_params="" # Compression parameters
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
archive_name="dump_$dateTime.tar"
command="$compression_executable $compression_params \"$absolute_backup_directory/$archive_name\" \"$absolute_server_directory\""


# Execute command
echo "$command"
eval "$command"


echo "End of dump"
sleep 5
