# VLC Looper

VLC Looper is a script for automatically preparing a device to play a video file in a loop using VLC.

The program configures access via SSH keys, installs VLC, uploads the presentation file to a remote device, starts playback, and allows you to set or disable the screen turn-on and turn-off timers. **Screen turn-on and turn-off scheduling is supported only for devices connected via DSI.**

## Features

- connects to a remote device over SSH,
- uses private and public SSH keys instead of a password,
- uploads a presentation file to the device,
- installs VLC,
- automatically starts the presentation in VLC,
- plays the presentation in a loop,
- allows setting the screen turn-on time,
- allows setting the screen turn-off time,
- allows disabling the screen turn-on and turn-off timers.

## Usage

Run the script with the Raspberry Pi SSH address, a video file path, and one timer option:

```bash
./vlc-looper.sh user@raspberry-pi-ip /path/to/video.mp4 ( --on HH:MM:SS --off HH:MM:SS | --disable-timer )
```

Example with backlight scheduling enabled:

```bash
./vlc-looper.sh pi@192.168.1.100 ./video.mp4 --on 05:00:00 --off 15:00:00
```

Example with backlight scheduling disabled:

```bash 
./vlc-looper.sh pi@192.168.1.100 ./video.mp4 --disable-timer
```

## Notes

The program automatically generates an SSH key pair. The private key stays on the local machine and is used by the program to connect to the Raspberry Pi. The user must manually upload the generated public key to the Raspberry Pi and add it to:

```bash
~/.ssh/authorized_keys
```