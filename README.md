# VLC Looper

VLC Looper is a script for automatically preparing a device to play a video file in a loop using VLC.

The program configures access via SSH keys, installs VLC, uploads the presentation file to a remote device, starts playback, and allows you to set or disable the screen turn-on and turn-off timers. **Screen turn-on and turn-off scheduling is supported only for devices connected via DSI.**

## Features

- connects to a remote device over SSH,
- uses private and public SSH keys instead of a password,
- supports custom SSH key path,
- uploads a presentation file to the device,
- installs VLC,
- automatically starts the presentation in VLC,
- plays the presentation in a loop,
- allows setting the screen turn-on time,
- allows setting the screen turn-off time,
- allows disabling the screen turn-on and turn-off timers.

## Installation
Before running the script, make it executable:

```bash
git clone https://github.com/mknnnnnnn/vlc-looper.git
cd vlc-looper
chmod +x install.sh
```

## Usage

Run the script with the Raspberry Pi SSH address, a video file path, and one timer option:

```bash
./install.sh user@raspberry-pi-ip /path/to/video.mp4 ( --on HH:MM:SS --off HH:MM:SS | --disable-timer ) [ --key-path /path/to/key ]
```

Example with backlight scheduling enabled:

```bash
./install.sh pi@192.168.1.100 ./video.mp4 --on 05:00:00 --off 15:00:00
```

Example with backlight scheduling disabled:

```bash 
./install.sh pi@192.168.1.100 ./video.mp4 --disable-timer
```

Example with custom SSH key path:

```bash
./install.sh pi@192.168.1.100 ./video.mp4 --on 05:00:00 --off 15:00:00 --key-path ~/.ssh/raspberry_pi_key
```

Example with disabled backlight timers and custom SSH key path:

```bash
./install.sh pi@192.168.1.100 ./video.mp4 --disable-timer --key-path ~/.ssh/raspberry_pi_key
```

## Notes

The program automatically generates an SSH key pair if the selected key file does not exist. By default, the key is created in:

```bash
~/.ssh/<SSH_USER>_<SERVER_IP>_ed25519
```

You can provide a custom SSH key path using:

```bash
--key-path /path/to/key
```

The private key stays on the local machine and is used by the program to connect to the Raspberry Pi.

The user must manually upload the generated public key to the Raspberry Pi and add it to:

```bash
~/.ssh/authorized_keys
```