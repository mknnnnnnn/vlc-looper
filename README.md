# VLC Looper

VLC Looper is a script for automatically preparing a device to play a video file in a loop using VLC.

The program configures access via SSH keys, installs VLC, uploads the presentation file to a remote device, starts playback, and allows you to set the screen turn-on and turn-off time. **Screen turn-on and turn-off scheduling is supported only for devices connected via DSI.**

## Features

- connects to a remote device over SSH,
- uses private and public SSH keys instead of a password,
- uploads a presentation file to the device,
- installs VLC,
- automatically starts the presentation in VLC,
- plays the presentation in a loop,
- allows setting the screen turn-on time,
- allows setting the screen turn-off time.

## Usage

Run the script with the Raspberry Pi SSH address and a video file path:

```bash 
./vlc-looper.sh user@raspberry-pi-ip /path/to/video.mp4 
```
Example:

```bash
 ./vlc-looper.sh pi@192.168.1.100 ./video.mp4 
```

### Schedule backlight on/off time

You can set the display backlight turn on and turn off time using --on and --off flags:

```bash 
./vlc-looper.sh user@raspberry-pi-ip /path/to/video.mp4 --on 05:00:00 --off 15:00:00 
```
Example:

```bash 
./vlc-looper.sh pi@192.168.1.50 ./video.mp4 --on 05:00:00 --off 23:00:00 
```

## Notes

The program automatically generates an SSH key pair. The private key stays on the local machine and is used by the program to connect to the Raspberry Pi. The user must manually upload the generated public key to the Raspberry Pi and add it to:

```bash
~/.ssh/authorized_keys
```