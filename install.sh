#!/bin/bash

if [[ -z "$1" || "$1" != *@* ]]; then
    echo "Example: $0 user@host [--key-path /path/to/key]"
    exit 1
fi

SERVER_IP="${1#*@}"
SSH_USER="${1%@*}"

if [[ "$2" == '--key-path' && -n "$3" ]]; then
    if [[ ! -f "$3" ]]; then
        echo "Key path does not exist: $3"
        exit 1
    fi
    SSH_KEY="$3"

else
    SSH_KEY="$HOME/.ssh/${SSH_USER}_ed25519"

    if [[ ! -f "$SSH_KEY" ]]; then
        if ! ssh-keygen -t ed25519 -C "${SSH_USER}_VLC_LOOPER" -f "$SSH_KEY"; then
            exit 1
        fi
    fi
fi

if ssh -i "$SSH_KEY" "${SSH_USER}@${SERVER_IP}" '
echo "Connected to Raspberry Pi"
sudo -n reboot >/dev/null 2>&1 &
'; then
    echo "Raspberry Pi is configured"
else
    echo 'Raspberry Pi is not configured'
    exit 1
fi
