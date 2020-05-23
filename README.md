# BTAudioSwitch
 A macOS command line tool to toggle Bluetooth devices and switch audio devices.
 
 *Note: This tool is primarily built for another [repository](https://github.com/noonchen/BTT_AppleWirelessHeadphone) of mine, but it can also be used for general purpose.*

## Usage
    `BTAudioSwitch <-switchOnly|-toggleOnly|-toggleSwitch> -devName="Device Name"`
---
**Commands:**

    `-switchOnly` 
Set the device given by `-devName` as the audio Input and Output device, an alert will be popped up if it's not found.

    `-toggleOnly`
Toggle the Bluetooth connection of the device given by `-devName`, an alert will be popped up if it's not paired before.

    `-toggleSwitch`
Toggle the Bluetooth connection of the device if:
- It's disconnected
- It's connected and is the audio input/output device

Set to the audio Input and Output device when:
- It's connected but is **NOT** the audio input/output device

---
**Required argument:**

    `-devName`
Specify the device name, use `""` around the name if contains spaces

## Examples

    `BTAudioSwitch -switchOnly -devName="MacBook Pro Speakers"`
Set `MacBook Pro Speakers` as the audio input/output device, if there's no input device has such name, then audio input device is not changed.

If the device is not found, an alert will show up and tell you the available audio devices in your mac.
![](/screenshots/alert_audio.png)

---
    `BTAudioSwitch -toggleOnly -devName="Bluetooth Keyboard"`
Toggle the connection of `Bluetooth Keyboard`.

If the device is not paired before, an alert will show up and tell you the paired Bluetooth devices in your mac.
![](/screenshots/alert_BT.png)

---
    `BTAudioSwitch -toggleSwitch -devName="AirPods Pro"`
Toggle the connection **OR** set as the audio device based on current device status.