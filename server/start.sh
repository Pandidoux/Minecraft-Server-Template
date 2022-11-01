#!/bin/bash

# ____________________________________________________________
# Server JAR file
serverJarPath="server.jar"
# Path to Java
if [[ "$OSTYPE" == "linux-gnu"* ]]; then # Linux
		javaExecutable="java"
elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OSX
		javaExecutable="java"
elif [[ "$OSTYPE" == "cygwin" ]]; then # POSIX compatibility layer and Linux environment emulation for Windows
		javaExecutable="java"
elif [[ "$OSTYPE" == "msys" ]]; then # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
		javaExecutable="\"C:/Program Files/Java/jre1.8.0_341/bin/java.exe\""
else # Unknown.
	javaExecutable="java"
fi
# Java arguments
javaArguments="-jar -Xms1G -Xmx4G"
# Server JAR arguments
jarArguments="--nogui"
# Reboot server when stoped or crash
looping=true
# Wait before server start
waiting=true
# ____________________________________________________________


# -------------------------
serverExecCommand="\"$javaExecutable\" $javaArguments $serverJarPath $jarArguments"
while [ $looping = true ]; do
	# -------------------------
	echo "#########################################"
	echo "#####   CTRL+C to stop the script   #####"
	echo "#########################################"
	if [ $waiting = true ]; then
		for countDown in 10 9 8 7 6 5 4 3 2 1 0
		do
			sleep 1
			echo "Server boot in: "$countDown
		done
	fi
	# -------------------------
	echo "________________________Server Start__________________________"
	echo $serverExecCommand
	eval $serverExecCommand
	echo "________________________Server Stop__________________________"
	# -------------------------
sleep 1
done
