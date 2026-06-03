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

if ! ssh -i "$SSH_KEY" "${SSH_USER}@${SERVER_IP}"; then
    echo 'Raspberry Pi is not configured'
    exit 1
fi

# VLC config

if ! ssh -i "$SSH_KEY" "${SSH_USER}@${SERVER_IP}" '
echo "Connected to Raspberry Pi"

    if ! command -v vlc >/dev/null 2>&1; then
        echo "VLC not found. Installing..."

        if ! sudo -n apt update || ! sudo -n apt install -y vlc; then
            echo "Failed to install VLC"
            exit 1
        else
            echo "VLC has been installed"
        fi
    else
        echo "VLC configured"
    fi
sudo -n reboot >/dev/null 2>&1 &
'; then
    echo "Raspberry Pi configuration failed"
    exit 1
fi

# Upload VLC service file

if ! sed "s/USER/${SSH_USER}/g" VLC.service > VLC.service.tmp; then
    echo "VLC.service should be in root file project"
    exit 1
fi

if ! scp -i "$SSH_KEY" VLC.service.tmp "${SSH_USER}@${SERVER_IP}":~/VLC.service; then
    echo "Raspberry Pi configuration failed"
    exit 1
fi

if ssh -i "$SSH_KEY" "${SSH_USER}@${SERVER_IP}" '
    cd ~
    sudo -n mv VLC.service /etc/systemd/system/VLC.service 
    sudo -n systemctl daemon-reload
    sudo -n systemctl enable VLC.service
'; then
    echo "VLC service configured"
    rm -f VLC.service.tmp
else
    echo "Raspberry Pi configuration failed"
    rm -f VLC.service.tmp
    exit 1
fi