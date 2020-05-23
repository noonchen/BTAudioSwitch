//
//  BTAudioSwitch.h
//  BTAudioSwitch
//
//  Created by Noon Chen on 2020/5/16.
//  Copyright © 2020 nochenon. All rights reserved.
//

#ifndef BTAudioSwitch_h
#define BTAudioSwitch_h
#endif /* BTAudioSwitch_h */

#import <CoreAudio/CoreAudio.h>
#import <IOBluetooth/IOBluetooth.h>

@interface Device: NSObject
{
    @public
    char *_name;
    IOBluetoothDevice *_BTDev;
    AudioDeviceID _AudioOuputID;
    AudioDeviceID _AudioInputID;
    AudioDeviceID _CurrentAOID;
    AudioDeviceID _CurrentAIID;
}

/* Init an instance by the device name*/
+ (instancetype)setName: (char *) DevName;

/* Make sure the device has been paired with your Mac. If the given device name is not correct OR the device is not paired before, an alert dialog would show up.
 Returns true if IOBluetoothDevice Instance of the specified device is successfully retrived. */
- (Boolean)getBluetoothDeviceInstance;

/* Toggle the connection of current Bluetooth device,
 returns true if the operation is successful, otherwise false. */
- (Boolean)toggleBTConnection;

/* Get the Input and Output ID of the current audio device And the device with the given name.
 Returns false if both the Input and Output ID are failed to get. */
- (Boolean)getAudioID: (Boolean) showAlert;

- (Boolean)isCurrentAudioDevice;

- (Boolean)setAsActiveAudioDevice;
@end
