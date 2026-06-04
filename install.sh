#!/bin/bash

# VLC Looper is a script for automatically preparing a device to play a video file in a loop using VLC.

if [[ -z "$1" || "$1" != *@* ]]; then
    echo "Example: $0 user@example.com /path/to/file"
    exit 1
fi

SERVER_IP="${1#*@}"
SSH_USER="${1%@*}"

SSH_KEY="$HOME/.ssh/${SSH_USER}_${SERVER_IP}_ed25519"

if [[ ! -f "$SSH_KEY" ]]; then
    if ! ssh-keygen -t ed25519 -C "${SSH_USER}_${SERVER_IP}_VLC_LOOPER" -f "$SSH_KEY"; then
        echo "Key generation failed"
        exit 1
    fi
fi
 
 
if ! ssh -i "$SSH_KEY" "${SSH_USER}@${SERVER_IP}" ""; then
    echo 'Raspberry Pi is not configured'
    exit 1
fi

# Upload video file

if [[ -n "$2" ]]; then
    if [[ -f "$2" ]]; then
        if scp -i "$SSH_KEY" "$2" "${SSH_USER}@${SERVER_IP}:~/video.mp4"; then
            echo "File has been sent"
        else
            echo "File send failed"
            exit 1
        fi
    else
        echo "File does not exist"
        exit 1
    fi
fi

# VLC configuration

if ! ssh -i "$SSH_KEY" "${SSH_USER}@${SERVER_IP}" '
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
'; then
    echo "Raspberry Pi configuration failed"
    exit 1
fi

# VLC service configuration

if ! sed "s/__USER__/${SSH_USER}/g" VLC.service > VLC.service.tmp; then
    echo "VLC.service should be in root file project"
    exit 1
fi

if ! scp -i "$SSH_KEY" VLC.service.tmp "${SSH_USER}@${SERVER_IP}":~/VLC.service; then
    echo "Raspberry Pi configuration failed"
    rm -f VLC.service.tmp
    exit 1
fi

if ssh -i "$SSH_KEY" "${SSH_USER}@${SERVER_IP}" '
    cd ~
    sudo -n mv VLC.service /etc/systemd/system/VLC.service 
    sudo -n systemctl daemon-reload
    sudo -n systemctl enable VLC.service
'; then
    echo "VLC service configured"
else
    echo "Raspberry Pi configuration failed"
    exit 1
fi

rm -f VLC.service.tmp

# Backlight service configuration

if ! scp -i "$SSH_KEY" backlight-off.timer backlight-on.timer backlight@.service "${SSH_USER}@${SERVER_IP}":~/; then
    echo "Raspberry Pi configuration failed"
    exit 1
fi

if ssh -i "$SSH_KEY" "${SSH_USER}@${SERVER_IP}" '
    cd ~
    sudo -n mv backlight-off.timer backlight-on.timer backlight@.service /etc/systemd/system/
    sudo -n systemctl daemon-reload
    sudo -n systemctl enable --now backlight-off.timer backlight-on.timer
'; then
    echo "Backlight service configured"
else
    echo "Raspberry Pi configuration failed"
    exit 1
fi