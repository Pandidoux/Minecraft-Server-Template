#!/bin/bash

# ______________________________GET PARAMETERS START______________________________
GLOBAL_EXIT_CODE=0
SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"
CONFIG=$(cat $SCRIPT_PATH/config.yml) # Read conf file

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
DUMPS_EXECUTABLE=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_DUMPS_EXECUTABLE:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
DUMPS_ARGUMENTS=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_DUMPS_ARGUMENTS:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
DUMPS_DIRECTORY=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_DUMPS_DIRECTORY:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
DUMPS_NAME=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_DUMPS_NAME:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
DUMPS_EXTENTION=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_DUMPS_EXTENTION:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
DUMPS_MAX=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_DUMPS_MAX:" | awk '{print $2}' | sed 's/^"\(.*\)"$/\1/')
DUMPS_REMOTE_ENABLE=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_DUMPS_REMOTE_ENABLE:" | awk '{print $2}' | sed 's/^"\(.*\)"$/\1/')
DUMPS_DIRECTORY_REMOTE=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_DUMPS_DIRECTORY_REMOTE:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
DUMPS_MAX_REMOTE=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_DUMPS_MAX_REMOTE:" | awk '{print $2}' | sed 's/^"\(.*\)"$/\1/')
DUMPS_PAUSE_AFTER_FINISH=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_DUMPS_PAUSE_AFTER_FINISH:" | awk '{print $2}' | sed 's/^"\(.*\)"$/\1/')

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
SCRIPT_PREFIX="${MAGENTA}[Dump]:${RESET}"

# Sever directory verification
if [ ! -d $SERVER_FOLDER_PATH ]; then # Not a valid directory
    echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_SERVER_FOLDER_PATH is not recognise as a directory => \"$SERVER_FOLDER_PATH\"${RESET}"
    exit 1
fi
# Executable verification
if ! which "$DUMPS_EXECUTABLE" >/dev/null; then # Not a valid command
    if [ ! -f "$DUMPS_EXECUTABLE" ]; then # Not a valid file
        echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_DUMPS_EXECUTABLE is not a valid executable => $DUMPS_EXECUTABLE${RESET}"
        exit 1
    fi
fi
# Dumps directory verification
if [ ! -d $DUMPS_DIRECTORY ]; then # Not a valid directory
    echo -e "$SCRIPT_PREFIX ${YELLOW}Create directory \"$DUMPS_DIRECTORY\"${RESET}"
    mkdir -p "$DUMPS_DIRECTORY"
    if [ ! $? -eq 0 ]; then
        echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_DUMPS_DIRECTORY is not recognise as a directory => \"$DUMPS_DIRECTORY\"${RESET}"
        exit 1
    fi
fi
# Integer verification
if echo "$DUMPS_MAX" | grep -vE '^[0-9]+$' >/dev/null; then # Not a valid integer
    echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_DUMPS_MAX is not a valid integer => $DUMPS_MAX${RESET}"
    exit 1
fi
# Boolean verification
if [ "$DUMPS_REMOTE_ENABLE" != "true" ] && [ "$DUMPS_REMOTE_ENABLE" != "false" ]; then
    echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_DUMPS_REMOTE_ENABLE is not a valid boolean => $DUMPS_REMOTE_ENABLE${RESET}"
    exit 1
fi
# Dumps remote directory verification
if [[ $DUMPS_REMOTE_ENABLE = "true" ]]; then
    # Dumps remote directory verification
    if [ ! -d $DUMPS_DIRECTORY_REMOTE ]; then # Not a valid directory
        echo -e "$SCRIPT_PREFIX ${YELLOW}Create directory \"$DUMPS_DIRECTORY_REMOTE\"${RESET}"
        mkdir -p "$DUMPS_DIRECTORY_REMOTE"
        if [ ! $? -eq 0 ]; then # Not a valid directory
            echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_DUMPS_DIRECTORY_REMOTE is not recognise as a directory => \"$DUMPS_DIRECTORY_REMOTE\"${RESET}"
            exit 1
        fi
    fi
    # Integer verification
    if echo "$DUMPS_MAX_REMOTE" | grep -vE '^[0-9]+$' >/dev/null; then # Not a valid integer
        echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_DUMPS_MAX_REMOTE is not a valid integer => $DUMPS_MAX_REMOTE${RESET}"
        exit 1
    fi
fi
# Boolean verification
if [ "$DUMPS_PAUSE_AFTER_FINISH" != "true" ] && [ "$DUMPS_PAUSE_AFTER_FINISH" != "false" ]; then
    echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_DUMPS_PAUSE_AFTER_FINISH is not a valid boolean => $DUMPS_PAUSE_AFTER_FINISH${RESET}"
    exit 1
fi
# ______________________________GET PARAMETERS END______________________________

# ______________________________SERVER DUMP START______________________________
DATE_TIME=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="${DUMPS_NAME}${DATE_TIME}${DUMPS_EXTENTION}"
ARCHIVE_PATH="${DUMPS_DIRECTORY}/${ARCHIVE_NAME}"

COMMAND="\"${DUMPS_EXECUTABLE}\" ${DUMPS_ARGUMENTS} \"${ARCHIVE_PATH}\" \"${SERVER_FOLDER_PATH}\""
echo -e "$SCRIPT_PREFIX ${YELLOW}Create dump using command: $COMMAND${RESET}"
eval "$COMMAND"
ARCHIVE_EXIT_CODE=$?
GLOBAL_EXIT_CODE=$ARCHIVE_EXIT_CODE
if [ $ARCHIVE_EXIT_CODE -ne 0 ]; then
    echo -e "$SCRIPT_PREFIX ${RED}ERROR during archive creation${RESET}"
    exit $ARCHIVE_EXIT_CODE
fi


if [[ $DUMPS_REMOTE_ENABLE = "true" ]]; then # Remote backup copy enabled
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
            SEND_COMMAND="rsync --archive --partial --info=progress2 \"${ARCHIVE_PATH}\" \"${DUMPS_DIRECTORY_REMOTE}\""
        elif [ $SEND_EXECUTABLE = "cp" ]; then
            SEND_COMMAND="cp \"${ARCHIVE_PATH}\" \"${DUMPS_DIRECTORY_REMOTE}\""
        fi

        echo -e "$SCRIPT_PREFIX ${YELLOW}Sending dump to remote with command: $SEND_COMMAND${RESET}"
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
            echo -e "$SCRIPT_PREFIX ${YELLOW}Delete backups in \"$DUMPS_DIRECTORY_REMOTE\" exept the $DUMPS_MAX most recent${RESET}"
            (ls "$DUMPS_DIRECTORY_REMOTE/" -tp | grep "^${DUMPS_NAME}" | tail -n +$(($DUMPS_MAX_REMOTE + 1)) | xargs -I {} rm -f -- "$DUMPS_DIRECTORY_REMOTE/{}")
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
    echo -e "$SCRIPT_PREFIX ${YELLOW}Delete backups in \"$DUMPS_DIRECTORY\" exept the $DUMPS_MAX most recent${RESET}"
    (ls "$DUMPS_DIRECTORY/" -tp | grep "^${DUMPS_NAME}" | tail -n +$(($DUMPS_MAX + 1)) | xargs -I {} rm -f -- "$DUMPS_DIRECTORY/{}")
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

if [ $DUMPS_PAUSE_AFTER_FINISH == "true" ]; then
    read -p "Press Enter to exit..."
fi


exit $GLOBAL_EXIT_CODE
# ________________________SERVER DUMP START END______________________________