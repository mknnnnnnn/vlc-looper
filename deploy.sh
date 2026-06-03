#!/bin/bash

if [[ -z "$1" || "$1" != *@* ]]; then
  echo "Usage: $0 user@host --file /path/to/file"
  exit 1
fi

SERVER_NAME="$1"

SERVER_IP="${SERVER_NAME#*@}"
SSH_USER="${SERVER_NAME%@*}"

SSH_KEY="$HOME/.ssh/${SERVER_IP}_ed25519"

if [[ ! -f "$SSH_KEY" ]]; then
  echo "SSH Key path not found: $SSH_KEY"
  exit 1
fi

if [[ "$2" == "--file" && -n "$3" ]]; then
  FILE_TO_SEND="$3"
else
  echo "Usage: $0 user@host --file /path/to/file"
  exit 1 
fi

if [[ ! -f "$FILE_TO_SEND" ]]; then
  echo "File does not exist: $FILE_TO_SEND"
  exit 1
fi

DEST_FILE_PATH="~/"

echo -e "Default destination ${DEST_FILE_PATH}\n"
echo "Processing $SERVER_NAME"

if scp -i "$SSH_KEY" "$FILE_TO_SEND" "${SSH_USER}@${SERVER_IP}:${DEST_FILE_PATH}"; then
  if ssh -i "$SSH_KEY" "${SSH_USER}@${SERVER_IP}" "sudo reboot"; then
    echo "File transfer and reboot on $SERVER_NAME completed"
    echo
    echo "Script finished"
  else
    echo "File was transferred, but reboot failed"
    exit 1
  fi
else
  echo "File transfer failed"
  exit 1
fi