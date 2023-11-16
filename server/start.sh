#!/bin/bash

# ______________________________GET PARAMETERS START______________________________
SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"
CONFIG=$(cat $SCRIPT_PATH/../config.yml) # Read conf file

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
# SERVER_FOLDER_PATH=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_SERVER_FOLDER_PATH:" | sed "s/^${OS_PREFIX}_SERVER_FOLDER_PATH: *\"\(.*\)\" *\$/\1/") # DELETE
USE_COLOR=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_USE_COLOR:" | awk '{print $2}' | sed 's/^"\(.*\)"$/\1/')
SERVER_FOLDER_PATH=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_SERVER_FOLDER_PATH:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
JAVA_EXECUTABLE=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_JAVA_EXECUTABLE:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
JAVA_ARGUMENTS=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_JAVA_ARGUMENTS:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
SERVER_JAR=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_SERVER_JAR:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
SERVER_JAR_ARGUMENTS=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_SERVER_JAR_ARGUMENTS:" | grep -oE '"([^"]*)"' | sed -E 's/^"|"$//g')
REBOOT_SERVER=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_REBOOT_SERVER:" | awk '{print $2}' | sed 's/^"\(.*\)"$/\1/')
BOOT_TIMER=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_BOOT_TIMER:" | awk '{print $2}' | sed 's/^"\(.*\)"$/\1/')
BOOTLOOP_MAX_CRASH=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_BOOTLOOP_MAX_CRASH:" | awk '{print $2}' | sed 's/^"\(.*\)"$/\1/')
BOOTLOOP_RESET_TIMER=$(echo "$CONFIG" | grep -E "^${OS_PREFIX}_BOOTLOOP_RESET_TIMER:" | awk '{print $2}' | sed 's/^"\(.*\)"$/\1/')

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
SCRIPT_PREFIX="${MAGENTA}[Start]:${RESET}"

# Sever directory verification
eval SERVER_FOLDER_PATH="$SERVER_FOLDER_PATH"
if [ ! -d "$SERVER_FOLDER_PATH" ]; then # Not a valid directory
    echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_SERVER_FOLDER_PATH is not recognise as a directory => $SERVER_FOLDER_PATH${RESET}"
    exit 1
fi
# Java executable verification
if ! which "$JAVA_EXECUTABLE" >/dev/null; then # Not a valid command
    if [ ! -f "$JAVA_EXECUTABLE" ]; then # Not a valid file
        echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_JAVA_EXECUTABLE is not a valid java executable => $JAVA_EXECUTABLE${RESET}"
        exit 1
    fi
fi
# Boolean verification
if [ $REBOOT_SERVER != "true" ] && [ $REBOOT_SERVER != "false" ]; then
    echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_REBOOT_SERVER is not a valid boolean => $REBOOT_SERVER${RESET}"
    exit 1
fi

# Integer verification
if echo "$BOOT_TIMER" | grep -vE '^[0-9]+$' >/dev/null; then # Not a valid integer
    echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_BOOT_TIMER is not a valid integer => $BOOT_TIMER${RESET}"
    exit 1
fi
# Integer verification
if echo "$BOOTLOOP_MAX_CRASH" | grep -vE '^[0-9]+$' >/dev/null; then # Not a valid integer
    echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_BOOTLOOP_MAX_CRASH is not a valid integer => $BOOTLOOP_MAX_CRASH${RESET}"
    exit 1
fi
# Integer verification
if echo "$BOOTLOOP_RESET_TIMER" | grep -vE '^[0-9]+$' >/dev/null; then # Not a valid integer
    echo -e "$SCRIPT_PREFIX ${RED}ERROR Parameter ${OS_PREFIX}_BOOTLOOP_RESET_TIMER is not a valid integer => $BOOTLOOP_RESET_TIMER${RESET}"
    exit 1
fi
# ______________________________GET PARAMETERS END______________________________

# ______________________________SERVER STARTING LOOP START______________________________
# Initialize some variables
COUNT=0
BOOTLOOP_COUNTER=0
LAST_SERVER_EXIT_CODE=0
cd "$SERVER_FOLDER_PATH"
while [[ $REBOOT_SERVER = "true" || $COUNT -eq 0 ]]; do
    COUNT=$COUNT+1
    echo -e "$SCRIPT_PREFIX ${YELLOW}#########################################${RESET}"
    echo -e "$SCRIPT_PREFIX ${YELLOW}#####   CTRL+C to stop the script   #####${RESET}"
    echo -e "$SCRIPT_PREFIX ${YELLOW}#########################################${RESET}"
    if [ $BOOT_TIMER -gt 0 ]; then
        for ((i = 0; i <= $BOOT_TIMER; i++)); do
            sleep 1
            secondsLeft=$(($BOOT_TIMER - $i))
            echo -e "$SCRIPT_PREFIX ${YELLOW}The server will boot in: $secondsLeft${RESET}"
        done
    fi
    echo -e "$SCRIPT_PREFIX ${YELLOW}______________________________ THE SERVER IS STARTING ______________________________${RESET}"
    # Get last matching jar (for server auto-update on reboot)
    SERVER_JAR_LATEST=$(find "$SERVER_FOLDER_PATH" -maxdepth 1 -name "$SERVER_JAR" -printf "%h/%f\n" | sort -r | head -1)
    if [ ! -f "$SERVER_JAR_LATEST" ]; then
        echo -e "$SCRIPT_PREFIX ${RED}ERROR Cannot find $SERVER_JAR file in directory $SERVER_FOLDER_PATH${RESET}"
        exit 1
    fi
    # Building start command
    SERVER_EXECUTION_COMMAND="\"$JAVA_EXECUTABLE\" $JAVA_ARGUMENTS $SERVER_JAR_LATEST $SERVER_JAR_ARGUMENTS"
    echo -e "$SCRIPT_PREFIX ${YELLOW}$SERVER_EXECUTION_COMMAND${RESET}" # Show the server start command
    START_DATE_TIME=$(date +%s) # Save the server start datetime
    eval $SERVER_EXECUTION_COMMAND # Run the server start command
    LAST_SERVER_EXIT_CODE=$? # Save the server exit code
    STOP_DATE_TIME=$(date +%s) # Save the server stop datetime
    # Show the server runing time
    diff=$(($STOP_DATE_TIME - $START_DATE_TIME))
    SERVER_RUN_TIME=$(date --date="@$diff" -u +$(($diff / 86400))days-%Hh:%Mm:%Ss)
    echo -e "$SCRIPT_PREFIX ${YELLOW}The server ran for $SERVER_RUN_TIME${RESET}"
    if [[ $LAST_SERVER_EXIT_CODE -ne 0 ]]; then
        # Hohoo... Server crashed ?
        echo -e "$SCRIPT_PREFIX ${RED}!!! SERVER CRASH !!! Exit code = $LAST_SERVER_EXIT_CODE${RESET}"
        if [[ $(($STOP_DATE_TIME - $START_DATE_TIME)) -lt $BOOTLOOP_RESET_TIMER ]]; then
            # Consider the server as crash during or juste after starting
            BOOTLOOP_COUNTER=$(($BOOTLOOP_COUNTER + 1))
            if [[ $BOOTLOOP_COUNTER -ge $BOOTLOOP_MAX_CRASH ]]; then
                # Consider the server is boot-REBOOT_SERVER and crashed too many time
                # Do not restart the server, exit script
                echo -e "$SCRIPT_PREFIX ${YELLOW}Server is enable to start after $BOOTLOOP_COUNTER/$BOOTLOOP_MAX_CRASH tries.${RESET}"
                echo -e "$SCRIPT_PREFIX ${YELLOW}Please try to fix the server and try again.${RESET}"
                echo -e "$SCRIPT_PREFIX ${YELLOW}Stop script with code $LAST_SERVER_EXIT_CODE${RESET}"
                exit $LAST_SERVER_EXIT_CODE
            fi
        fi
    else
        # Server as run enougth time to reset the boot-loop counter
        BOOTLOOP_COUNTER=0
    fi
    echo -e "$SCRIPT_PREFIX ${YELLOW}______________________________ THE SERVER IS STOPED ______________________________${RESET}"
    if [[ $REBOOT_SERVER = "true" ]]; then
        if [[ $LAST_SERVER_EXIT_CODE -eq 0 ]]; then
            echo -e "$SCRIPT_PREFIX ${YELLOW}Restart after stop${RESET}"
        fi
        if [[ $LAST_SERVER_EXIT_CODE -ne 0 && $BOOTLOOP_COUNTER -gt 0 ]]; then
            echo -e "$SCRIPT_PREFIX ${YELLOW}Restart after crash: Retry $BOOTLOOP_COUNTER/$BOOTLOOP_MAX_CRASH${RESET}"
        fi
    fi
done
# ________________________SERVER STARTING LOOP START END______________________________
