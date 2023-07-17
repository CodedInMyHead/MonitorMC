#!/bin/bash

SERVER_PATH="/setup"  # Path to server directory
EULA_FILE="$SERVER_PATH/eula.txt" # Location of expected eula file
MIN_GB=1G # Min amount of GB to use for the Server
MAX_GB=8G # Max amount of GB to use for the Server

chmod -R a+rwx $SERVER_PATH # Change permissions to make files readable
java -Xms"${MIN_GB}" -Xmx"${MAX_GB}" -jar "$SERVER_PATH/server.jar" nogui || # Start server to generate files
chmod -R a+rwx $SERVER_PATH # Required for next step (idk why)
echo "eula=true" > eula.txt # Change eula=false to true
chmod -R a+rwx $SERVER_PATH # Make everything readable
java -Xms"${MIN_GB}" -Xmx"${MAX_GB}" -jar "$SERVER_PATH/server.jar" nogui # Final start with all files there