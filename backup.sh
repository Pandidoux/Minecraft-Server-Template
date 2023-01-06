#!/bin/bash

# ______________________________GET PARAMETERS START______________________________
GLOBAL_EXIT_CODE=0
SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"
CONFIG=$(cat $SCRIPT_PATH/config.yml) # Read conf file

PLUGINS_BACKUP=0
if [[ ! -z "$1" ]]; then
    # backup from EssentialsX plugin while server is still running
    if [[ "$1" = "--essentials" ]]; then
        PLUGINS_BACKUP=1
    fi
fi

# OS detection
if [[ "$OSTYPE" == "linux-gnu"* ]]; then # Linux
    OS_PREFIX="LINUX"
elif [[ "$OSTYPE" == "msys" ]]; then # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    OS_PREFIX="WIN"
elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OSX
    OS_PREFIX="MAC"
elif [[ "$OSTYPE" == "cygwin" ]]; then # POSIX compatibility layer and Linux environment emulation for Windows
    OS_PREFIX="POSIX"
else # Unknown OS
    echo "ERROR Unknown OS"
    exit 1
fi

# Assigning conf to variables
USE_COLOR=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_USE_COLOR:" | awk '{print $2}' | sed 's/^"\(.*\)"$/\1/')
SERVER_FOLDER_PATH=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_SERVER_FOLDER_PATH:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
BACKUPS_EXECUTABLE=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_BACKUPS_EXECUTABLE:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
BACKUPS_ARGUMENTS=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_BACKUPS_ARGUMENTS:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
BACKUPS_DIRECTORY=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_BACKUPS_DIRECTORY:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
BACKUPS_NAME=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_BACKUPS_NAME:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
BACKUPS_EXTENTION=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_BACKUPS_EXTENTION:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
BACKUPS_ITEMS=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_BACKUPS_ITEMS: \[[^]]*\]" | grep -o '\[[^]]*\]')
BACKUPS_MAX=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_BACKUPS_MAX:" | awk '{print $2}' | sed 's/^"\(.*\)"$/\1/')
BACKUPS_REMOTE_ENABLE=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_BACKUPS_REMOTE_ENABLE:" | awk '{print $2}' | sed 's/^"\(.*\)"$/\1/')
BACKUPS_DIRECTORY_REMOTE=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_BACKUPS_DIRECTORY_REMOTE:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
BACKUPS_MAX_REMOTE=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_BACKUPS_MAX_REMOTE:" | awk '{print $2}' | sed 's/^"\(.*\)"$/\1/')
BACKUPS_PAUSE_AFTER_FINISH=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_BACKUPS_PAUSE_AFTER_FINISH:" | awk '{print $2}' | sed 's/^"\(.*\)"$/\1/')

# Boolean verification
if [ "$USE_COLOR" != "true" ] && [ "$USE_COLOR" != "false" ]; then
    echo "ERROR Parameter ${OS_PREFIX}_USE_COLOR is not a valid boolean => $USE_COLOR"
    exit 1
fi

# Console support color
if [[ "$USE_COLOR" == "true" || -n $COLORTERM || ($TERM == *color* && $TERM_PROGRAM != *iTerm.app*) || $CLICOLOR -eq 1 ]]; then
    RED="\033[31m"
    GREEN="\033[32m"
    YELLOW="\033[33m"
    BLUE="\033[34m"
    MAGENTA="\033[35m"
    CYAN="\033[36m"
    RESET="\033[0m"
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    MAGENTA=""
    CYAN=""
    RESET=""
fi
SCRIPT_PREFIX="${MAGENTA}[Backup]:${RESET}"

# Sever directory verification
if [ ! -d $SERVER_FOLDER_PATH ]; then # Not a valid directory
    echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_SERVER_FOLDER_PATH is not recognise as a directory => \"$SERVER_FOLDER_PATH\"${RESET}"
    exit 1
fi
# Executable verification
if ! which "$BACKUPS_EXECUTABLE" >/dev/null; then # Not a valid command
    if [ ! -f "$BACKUPS_EXECUTABLE" ]; then # Not a valid file
        echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_BACKUPS_EXECUTABLE is not a valid executable => $BACKUPS_EXECUTABLE${RESET}"
        exit 1
    fi
fi
# Backups directory verification
if [ ! -d $BACKUPS_DIRECTORY ]; then # Not a valid directory
    echo -e "$SCRIPT_PREFIX ${YELLOW}Create directory $BACKUPS_DIRECTORY${RESET}"
    mkdir -p "$BACKUPS_DIRECTORY"
    if [ ! $? -eq 0 ]; then
        echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_BACKUPS_DIRECTORY is not recognise as a directory => \"$BACKUPS_DIRECTORY\"${RESET}"
        exit 1
    fi
fi
# Integer verification
if echo "$BACKUPS_MAX" | grep -vE '^[0-9]+$' >/dev/null; then # Not a valid integer
    echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_BACKUPS_MAX is not a valid integer => $BACKUPS_MAX${RESET}"
    exit 1
fi
# Boolean verification
if [ "$BACKUPS_REMOTE_ENABLE" != "true" ] && [ "$BACKUPS_REMOTE_ENABLE" != "false" ]; then
    echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_BACKUPS_REMOTE_ENABLE is not a valid boolean => $BACKUPS_REMOTE_ENABLE${RESET}"
    exit 1
fi
# Backups remote directory verification
if [[ $BACKUPS_REMOTE_ENABLE = "true" ]]; then
    # Backups remote directory verification
    if [ ! -d $BACKUPS_DIRECTORY_REMOTE ]; then # Not a valid directory
        echo -e "$SCRIPT_PREFIX ${YELLOW}Create directory \"$BACKUPS_DIRECTORY_REMOTE\"${RESET}"
        mkdir -p "$BACKUPS_DIRECTORY_REMOTE"
        if [ ! $? -eq 0 ]; then # Not a valid directory
            echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_BACKUPS_DIRECTORY_REMOTE is not recognise as a directory => \"$BACKUPS_DIRECTORY_REMOTE\"${RESET}"
            exit 1
        fi
    fi
    # Integer verification
    if echo "$BACKUPS_MAX_REMOTE" | grep -vE '^[0-9]+$' >/dev/null; then # Not a valid integer
        echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_BACKUPS_MAX_REMOTE is not a valid integer => $BACKUPS_MAX_REMOTE${RESET}"
        exit 1
    fi
fi
# Boolean verification
if [ "$BACKUPS_PAUSE_AFTER_FINISH" != "true" ] && [ "$BACKUPS_PAUSE_AFTER_FINISH" != "false" ]; then
    echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_BACKUPS_PAUSE_AFTER_FINISH is not a valid boolean => $BACKUPS_PAUSE_AFTER_FINISH${RESET}"
    exit 1
fi
# ______________________________GET PARAMETERS END______________________________

# ______________________________SERVER BACKUP START______________________________
DATE_TIME=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="${BACKUPS_NAME}${DATE_TIME}${BACKUPS_EXTENTION}"
ARCHIVE_PATH="${BACKUPS_DIRECTORY}/${ARCHIVE_NAME}"

ITEMS=$(echo "$BACKUPS_ITEMS" | grep -o '"[^"]*"')
array=()
ITEM_LIST=""
while read -r ITEM; do
    ITEM=$(echo "$ITEM" | sed 's/^"\(.*\)"$/\1/')
    if [ -z "$ITEM_LIST" ]; then
        ITEM_LIST="\"${SERVER_FOLDER_PATH}/$ITEM\""
    else
        ITEM_LIST="$ITEM_LIST \"${SERVER_FOLDER_PATH}/$ITEM\""
    fi
done <<< "$ITEMS"

COMMAND="\"${BACKUPS_EXECUTABLE}\" ${BACKUPS_ARGUMENTS} \"${ARCHIVE_PATH}\" ${ITEM_LIST}"
echo -e "$SCRIPT_PREFIX ${YELLOW}Create backup using command: $COMMAND${RESET}"
eval "$COMMAND"
ARCHIVE_EXIT_CODE=$?
GLOBAL_EXIT_CODE=$ARCHIVE_EXIT_CODE
if [ $ARCHIVE_EXIT_CODE -ne 0 ]; then
    echo -e "$SCRIPT_PREFIX ${RED}ERROR during archive creation${RESET}"
    exit $ARCHIVE_EXIT_CODE
fi


if [[ $BACKUPS_REMOTE_ENABLE = "true" ]]; then # Remote backup copy enabled
    # Select copy method
    if which rsync &> /dev/null; then # Not a valid command
        SEND_EXECUTABLE="rsync"
    else
        if which cp &> /dev/null; then # Not a valid command
            SEND_EXECUTABLE="cp"
        else
            SEND_EXECUTABLE="none"
            echo -e "$SCRIPT_PREFIX ${RED}ERROR Command cp not available, unable to send archive to remote${RESET}"
            if [ ! $GLOBAL_EXIT_CODE -eq 0 ]; then
                GLOBAL_EXIT_CODE=1
            fi
        fi
    fi

    if [ ! $SEND_EXECUTABLE = "none" ]; then

        if [ $SEND_EXECUTABLE = "rsync" ]; then
            SEND_COMMAND="rsync --archive --partial --info=progress2 \"${ARCHIVE_PATH}\" \"${BACKUPS_DIRECTORY_REMOTE}\""
        elif [ $SEND_EXECUTABLE = "cp" ]; then
            SEND_COMMAND="cp \"${ARCHIVE_PATH}\" \"${BACKUPS_DIRECTORY_REMOTE}\""
        fi

        echo -e "$SCRIPT_PREFIX ${YELLOW}Sending backup to remote with command: $SEND_COMMAND${RESET}"
        # Retry max 3 times to copy
        COPY_ATTEMPT=1
        while [ $COPY_ATTEMPT -le 3 ]; do
            eval "$SEND_COMMAND"
            COPY_EXIT_CODE=$?
            if [ ! $GLOBAL_EXIT_CODE -eq 0 ]; then
                GLOBAL_EXIT_CODE=$COPY_EXIT_CODE
            fi
            if [ $COPY_EXIT_CODE -eq 0 ]; then
                break
            fi
            COPY_ATTEMPT=$((COPY_ATTEMPT+1))
            echo -e "$SCRIPT_PREFIX ${RED}ERROR Copy to remote directory failed${RESET}"
        done

        if [ $COPY_EXIT_CODE -eq 0 ]; then
            # Keep only N most recents backups (remote)
            echo -e "$SCRIPT_PREFIX ${YELLOW}Delete backups in \"$BACKUPS_DIRECTORY_REMOTE\" exept the $BACKUPS_MAX_REMOTE most recent${RESET}"
            (ls "$BACKUPS_DIRECTORY_REMOTE/" -tp | grep "^${BACKUPS_NAME}" | tail -n +$(($BACKUPS_MAX_REMOTE + 1)) | xargs -I {} rm -f -- "$BACKUPS_DIRECTORY_REMOTE/{}")
            DELETE_REMOTE_EXIT_CODE=$?
            if [ ! $GLOBAL_EXIT_CODE -eq 0 ]; then
                GLOBAL_EXIT_CODE=$DELETE_REMOTE_EXIT_CODE
            fi
            if [ $DELETE_REMOTE_EXIT_CODE -ne 0 ]; then
                exit $DELETE_REMOTE_EXIT_CODE
            fi
        fi

    fi

fi


if [ $ARCHIVE_EXIT_CODE -eq 0 ]; then
    # Keep only N most recents backups
    echo -e "$SCRIPT_PREFIX ${YELLOW}Delete backups in \"$BACKUPS_DIRECTORY\" exept the $BACKUPS_MAX most recent${RESET}"
    (ls "$BACKUPS_DIRECTORY/" -tp | grep "^${BACKUPS_NAME}" | tail -n +$(($BACKUPS_MAX + 1)) | xargs -I {} rm -f -- "$BACKUPS_DIRECTORY/{}")
    DELETE_EXIT_CODE=$?
    if [ ! $GLOBAL_EXIT_CODE -eq 0 ]; then
        GLOBAL_EXIT_CODE=$DELETE_EXIT_CODE
    fi
    if [ $DELETE_EXIT_CODE -ne 0 ]; then
        exit $DELETE_EXIT_CODE
    fi
fi


if [ $GLOBAL_EXIT_CODE -eq 0 ]; then
    echo -e "$SCRIPT_PREFIX ${GREEN}Backup successful !!!${RESET}"
else
    echo -e "$SCRIPT_PREFIX ${RED}An error as occured...${RESET}"
fi

if [ $BACKUPS_PAUSE_AFTER_FINISH == "true" ]; then
    if [ $PLUGINS_BACKUP -ne 1 ]; then
        read -p "Press Enter to exit..."
    fi
fi


exit $GLOBAL_EXIT_CODE
# ________________________SERVER BACKUP START END______________________________