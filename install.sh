#!/bin/bash

# VLC Looper is a script for automatically preparing a device to play a video file in a loop using VLC.

USAGE="Example: $0 user@example.com /path/to/file ( --on 05:00:00 --off 15:00:00 | --disable-timer ) [ --key-path /path/to/key ]"

if [[ -z "$1" || "$1" != *@* ]]; then
    echo "$USAGE"
    exit 1
fi

SERVER_IP="${1#*@}"
SSH_USER="${1%@*}"

if [[ "$3" == "--disable-timer" && "$4" == "--key-path" ]]; then
    SSH_KEY="$5"
elif [[ "$3" == "--on" && "$5" == "--off" && "$7" == "--key-path" ]]; then
    SSH_KEY="$8"
else
    SSH_KEY="$HOME/.ssh/${SSH_USER}_${SERVER_IP}_ed25519"
fi

if [[ -z "$SSH_KEY" ]]; then
    echo "$USAGE"
    exit 1
fi

if [[ ! -f "$SSH_KEY" ]]; then
    if ! ssh-keygen -t ed25519 -C "${SSH_USER}_${SERVER_IP}_VLC_LOOPER" -f "$SSH_KEY"; then
        echo "Key generation failed"
        exit 1
    else 
        echo "Key generated successfully"
    fi
fi
 
if ! ssh -i "$SSH_KEY" "${SSH_USER}@${SERVER_IP}" "true"; then
    echo 'Raspberry Pi is not configured'
    exit 1
fi

# Upload video file

if [[ -z "$2" ]]; then
    echo "$USAGE"
    exit 1
fi

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

if [[ "$3" == "--disable-timer" ]]; then
    DISABLE_TIMER=true
elif [[ "$3" == "--on" && "$5" == "--off" ]]; then
    DISABLE_TIMER=false
else
    echo "$USAGE"
    exit 1
fi

# Set turn on / off time

if [[ "$DISABLE_TIMER" == false ]]; then
    if [[ "$3" == "--on" ]]; then
        if [[ "$4" == ??:??:?? ]]; then
            if sed "s/^OnCalendar=.*/OnCalendar=*-*-* $4/" backlight-on.timer > backlight-on.timer.tmp; then
                mv backlight-on.timer.tmp backlight-on.timer
            else
                echo "Failed to update backlight-on.timer"
                rm -f backlight-on.timer.tmp
                exit 1
            fi
        else
            echo "Bad input value: $4"
            exit 1  
        fi
    fi

    if [[ "$5" == "--off" ]]; then
        if [[ "$6" == ??:??:?? ]]; then
            if sed "s/^OnCalendar=.*/OnCalendar=*-*-* $6/" backlight-off.timer > backlight-off.timer.tmp; then
                mv backlight-off.timer.tmp backlight-off.timer
            else
                echo "Failed to update backlight-off.timer"
                rm -f backlight-off.timer.tmp
                exit 1
            fi
        else
            echo "Bad input value: $6"
            exit 1
        fi
    fi
fi

if [[ "$DISABLE_TIMER" == true ]]; then
    TIMER="sudo -n systemctl disable --now backlight-on.timer backlight-off.timer"
else
    TIMER="sudo -n systemctl enable --now backlight-on.timer backlight-off.timer"
fi

if ! scp -i "$SSH_KEY" backlight-off.timer backlight-on.timer backlight@.service backlightctl "${SSH_USER}@${SERVER_IP}":~/; then
    echo "Raspberry Pi configuration failed"
    exit 1
fi

if ssh -i "$SSH_KEY" "${SSH_USER}@${SERVER_IP}" "
    cd ~
    
    sudo -n chmod +x backlightctl
    sudo -n mv backlightctl /usr/bin/
    sudo -n mv backlight-off.timer backlight-on.timer backlight@.service /etc/systemd/system/

    sudo -n systemctl daemon-reload
    $TIMER
"; then
    echo "Backlight service configured"
else
    echo "Raspberry Pi configuration failed"
    exit 1
fi

# Turn off password authentication

if ssh -i "$SSH_KEY" "${SSH_USER}@${SERVER_IP}" '
    sudo -n sed -i "s/^#\?passwordauthentication .*/PasswordAuthentication no/I" /etc/ssh/sshd_config
    sudo -n systemctl restart ssh
'; then
    echo "Password authentication has been turned off"
else
    echo "Raspberry Pi configuration failed"
    exit 1
fi

ssh -i "$SSH_KEY" "${SSH_USER}@${SERVER_IP}" 'sudo -n reboot >/dev/null 2>&1 &' || true

echo "Raspberry Pi has been successfully configured"

