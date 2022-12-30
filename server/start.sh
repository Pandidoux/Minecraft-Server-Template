 #!/bin/bash

 # ______________________________START PARAMETERS______________________________
 # Server JAR file (accept "server-*.jar" patern lastest version will be choosen)
serverJar="paper-1.19.2-*.jar"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then # Linux
    javaExecutable="java" # Path to Java
    javaArguments="-jar -Xms1G -Xmx6G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true" # Java arguments
    jarArguments="nogui" # Server JAR arguments
    looping=false # Reboot server when stoped or crash
    timer=10 # Wait before server start
    maxBootLoopCrash=5 # Max restart try after a crash during or just after starting the server (prevent infinite boot-loop)
    crashLoopMinTimer=300 # Time after considering the server is started without any crash (in seconds)
    elif [[ "$OSTYPE" == "msys" ]]; then # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    javaExecutable="/c/Program Files/Java/jdk-17.0.1/bin/java.exe" # Path to Java
    javaArguments="-jar -Xms1G -Xmx6G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true" # Java arguments
    jarArguments="nogui" # Server JAR arguments
    looping=true # Reboot server when stoped or crash
    timer=10 # Wait before server start
    maxBootLoopCrash=5 # Max restart try after a crash during or just after starting the server (prevent infinite boot-loop)
    crashLoopMinTimer=300 # Time after considering the server is started without any crash (in seconds)
    elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OSX
    javaExecutable="" # Path to Java
    javaArguments="" # Java arguments
    jarArguments="" # Server JAR arguments
    looping=true # Reboot server when stoped or crash
    timer=10 # Wait before server start
    maxBootLoopCrash=5 # Max restart try after a crash during or just after starting the server (prevent infinite boot-loop)
    crashLoopMinTimer=300 # Time after considering the server is started without any crash (in seconds)
    elif [[ "$OSTYPE" == "cygwin" ]]; then # POSIX compatibility layer and Linux environment emulation for Windows
    javaExecutable="" # Path to Java
    javaArguments="" # Java arguments
    jarArguments="" # Server JAR arguments
    looping=true # Reboot server when stoped or crash
    timer=10 # Wait before server start
    maxBootLoopCrash=5 # Max restart try after a crash during or just after starting the server (prevent infinite boot-loop)
    crashLoopMinTimer=300 # Time after considering the server is started without any crash (in seconds)
else # Unknown OS
    javaExecutable="java" # Path to Java
    javaArguments="-jar -Xms1G -Xmx4G" # Java arguments
    jarArguments="nogui" # Server JAR arguments
    looping=true # Reboot server when stoped or crash
    timer=10 # Wait before server start
    maxBootLoopCrash=5 # Max restart try after a crash during or just after starting the server (prevent infinite boot-loop)
    crashLoopMinTimer=300 # Time after considering the server is started without any crash (in seconds)
fi
 # ______________________________END PARAMETERS______________________________

 # ______________________________BEGIN SERVER STARTING LOOP______________________________
 # Initialize some variables
scriptPath="$(dirname -- "${BASH_SOURCE[0]}")"
count=0
bootLoopCounter=0
lastExitCode=0
scriptPrefix="[Script]:"
cd "$scriptPath"
while [[ $looping = true || $count -eq 0 ]]; do
    count=$count+1
	echo "$scriptPrefix #########################################"
	echo "$scriptPrefix #####   CTRL+C to stop the script   #####"
	echo "$scriptPrefix #########################################"
    if [ $timer -gt 0 ]; then
        for ((i = 0; i <= $timer; i++)); do
            sleep 1
            secondsLeft=$(($timer - $i))
            echo "$scriptPrefix The server will boot in: $secondsLeft"
        done
    fi
    echo "$scriptPrefix ______________________________ THE SERVER IS STARTING ______________________________"
 # Get last matching jar (for server auto-update on reboot)
    serverJarLastest=$(find "$scriptPath" -maxdepth 1 -name "$serverJar" -printf "%f\n" | sort | tail -1)
 # Building start command
    serverExecCommand="\"$javaExecutable\" $javaArguments $serverJarLastest $jarArguments"
 # Show the server start command
    echo $serverExecCommand
 # Save the server start datetime
    startDateTime=$(date +%s)
 # Run the server start command
    eval $serverExecCommand
 # Save the server stop datetime
    stopDateTime=$(date +%s)
 # Show the server runing time
    diff=$(($stopDateTime - $startDateTime))
    runningTime=$(date --date="@$diff" -u +$(($diff / 86400))days-%Hh:%Mm:%Ss)
    echo "$scriptPrefix The server ran for $runningTime"
    lastExitCode=$?
    if [[ $lastExitCode -ne 0 ]]; then
 # Hohoo... Server crashed ?
        echo "$scriptPrefix !!! SERVER CRASH !!! Exit code = $lastExitCode"
        if [[ $(($stopDateTime - $startDateTime)) -lt $crashLoopMinTimer ]]; then
 # Consider the server as crash during or juste after starting
            bootLoopCounter=$(($bootLoopCounter + 1))
            if [[ $bootLoopCounter -ge $maxBootLoopCrash ]]; then
 # Consider the server boot-looping and crashed too many time
 # Do not restart the server, exit the start script
                echo "$scriptPrefix Server is enable to start after $bootLoopCounter/$maxBootLoopCrash tries."
                echo "$scriptPrefix Please try to fix the server and try again."
                echo "$scriptPrefix Stop script with code $lastExitCode"
                exit $lastExitCode
            fi
        fi
    else
 # Server as run enougth time to reset the boot-loop counter
        bootLoopCounter=0
    fi
    echo "$scriptPrefix ______________________________ THE SERVER IS STOPED ______________________________"
    if [[ $looping = true ]]; then
        if [[ $lastExitCode -eq 0 ]]; then
            echo "$scriptPrefix Restart after stop"
        fi
        if [[ $lastExitCode -ne 0 && $bootLoopCounter -gt 0 ]]; then
            echo "$scriptPrefix Restart after crash: Retry $bootLoopCounter/$maxBootLoopCrash"
        fi
    fi
done
 # ______________________________FINISH SERVER STARTING LOOP______________________________
