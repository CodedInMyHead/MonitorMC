#!/bin/bash

SERVER_PATH="/minecraft/server-files"  # 
EULA_FILE="$SERVER_PATH/eula.txt"

chmod -R a+r $SERVER_PATH

java -Xms2G -Xmx4G -jar "$SERVER_PATH/server.jar" nogui || 
chmod -R a+r $SERVER_PATH &&
echo "eula=true" > eula.txt
chmod -R a+r $SERVER_PATH &&
java -Xms2G -Xmx4G -jar "$SERVER_PATH/server.jar" nogui