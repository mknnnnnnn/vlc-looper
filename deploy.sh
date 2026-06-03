#!/bin/bash

if [[ "$1" == "--server" ]]; then
  SERVER_NAME="$2"
  echo "Server name: $2"
else
  echo "Usage: $0 --server user@host --file ./file"
  exit 1
fi

SERVER_IP="${SERVER_NAME#*@}"
SSH_USER="${SERVER_NAME%*@}"

SSH_KEY="$HOME/.ssh/id_rsa"

if [[ ! -f "$SSH_KEY" ]]; then
  echo "Default SSH Key path not found"
else
  echo "Default SSH Key path: ${SSH_KEY}"
fi

if [[ "$3" == "--file" ]]; then
  FILE_TO_SEND="$4"
fi

if [[ ! -f "$FILE_TO_SEND" ]]; then
  echo "File does not exists: $FILE_TO_SEND"
  exit 1
fi

DEST_FILE_PATH="~/" 
echo "Default destination $DEST_FILE_PATH"
  
echo "Processing: $SERVER_NAME"

if scp -i "$SSH_KEY" "$FILE_TO_SEND" "$SSH_USER@$SERVER_IP:$DEST_FILE_PATH"; then
  ssh -i "$SSH_KEY" "$SSH_USER@$SERVER_IP" "sudo reboot"
else
  echo "Error"
  exit 1
fi

echo -e "File transfer and reboot on $SERVER_NAME completed\n"

echo "Script finished"
