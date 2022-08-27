#!/bin/bash

# ____________________________________________________________
# Server installer JAR file
serverInstallerJar="server-installer.jar"
# Server JAR file
serverJar="server.jar"
# Path to Java
javaExecutable="/c/Program Files/Java/jre1.8.0_341/bin/java.exe"
# Java arguments
javaArguments="-jar -Xms1G -Xmx2G"
# Server JAR arguments
jarArguments="nogui"
# ____________________________________________________________

# -------------------------
# Commands build
commandServerBuild="\"$javaExecutable\" -jar \"$serverInstallerJar\""
commandServerStart="\"$javaExecutable\" $javaArguments \"$serverJar\" $jarArguments"
commandEulaAccept="echo \"eula=true\" > eula.txt"
# -------------------------
# Execute commands
echo "Build server"
read -p "Press Enter to continue"
eval $commandServerBuild
# -------------------------
echo "First start server"
read -p "Press Enter to continue"
eval $commandServerStart
# -------------------------
echo "auto accept eula"
read -p "Press Enter to continue"
eval $commandEulaAccept
# -------------------------
echo "Start server"
read -p "Press Enter to continue"
eval $commandServerStart
# -------------------------
echo "End Setup"
read -p "Press Enter to exit"
# -------------------------
