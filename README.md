# VLC Looper

VLC Looper is a script for automatically preparing a device to play a video file in a loop using VLC.

The program installs VLC, configures access via SSH keys, uploads the presentation file to a remote device, starts playback, and allows you to set the screen turn-on and turn-off time. **Screen turn-on and turn-off scheduling is supported only for devices connected via DSI.**

## Features

- connects to a remote device over SSH,
- uses private and public SSH keys instead of a password,
- uploads a presentation file to the device,
- installs VLC,
- automatically starts the presentation in VLC,
- plays the presentation in a loop,
- allows setting the screen turn-on time,
- allows setting the screen turn-off time.

## Notes

The program automatically generates an SSH key pair.

The private key stays on the local machine and is used by the program to connect to the Raspberry Pi.

The user must manually upload the generated public key to the Raspberry Pi and add it to:

```bash
~/etc/ssh/
```