//
//  BTAudioSwitch.m
//  BTAudioSwitch
//
//  Created by Noon Chen on 2020/5/17.
//  Copyright © 2020 nochenon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CFUserNotification.h>
#import "BTAudioSwitch.h"

// Address for retriving devIDs of Input/Output devices
AudioObjectPropertyAddress propertyAddress = {
    kAudioHardwarePropertyDevices,
    kAudioObjectPropertyScopeGlobal,
    kAudioObjectPropertyElementMaster
};
// Address for retriving DevNames
AudioObjectPropertyAddress devNameAddress = {
    kAudioDevicePropertyDeviceName,
    kAudioObjectPropertyScopeGlobal,
    kAudioObjectPropertyElementMaster
};
// Address for get/set output device
AudioObjectPropertyAddress devOutAddress = {
    kAudioHardwarePropertyDefaultOutputDevice,
    kAudioDevicePropertyScopeOutput,
    kAudioObjectPropertyElementMaster
};
// Address for get/set Input device
AudioObjectPropertyAddress devInAddress = {
    kAudioHardwarePropertyDefaultInputDevice,
    kAudioDevicePropertyScopeInput,
    kAudioObjectPropertyElementMaster
};

@implementation Device
+ (instancetype)setName:(char *)DevName{
    // Use this class method to initialize an instance
    Device *dev = [[Device alloc] init];
    if (dev) {
        // set default value
        dev->_name = DevName;
        dev->_AudioInputID = 0;
        dev->_AudioOuputID = 0;
        dev->_CurrentAIID = 0;
        dev->_CurrentAOID = 0;
    }
    return dev;
};

- (Boolean)getBluetoothDeviceInstance{
    NSString *devName = [NSString stringWithUTF8String: self->_name];
    NSArray *pairedDevs = [IOBluetoothDevice pairedDevices];
    
    NSString *Message = @"❗️Check the device name or manually connect the Bluetooth headphones first.\n\nCurrent paired Bluetooth devices are listed below:";
    
    for (int i = 0; i < pairedDevs.count; i++) {
        IOBluetoothDevice *BTObj = pairedDevs[i];
        
        if ([devName isEqualToString: BTObj.name]) {
            self->_BTDev = BTObj;
            return true;
        }
        else {
            // Add mismatch device name to ErrorMessage
            Message = [Message stringByAppendingFormat:@"\n➤  %@", BTObj.name];
        }
    }
    
    NSString *Header = [@"" stringByAppendingFormat:@"\"%@\" cannot be found in paired Bluetooth devices", devName];
    Message = (pairedDevs.count == 0)? @"No paired Bluetooth device is detected" : Message;
    CFUserNotificationDisplayNotice(0, kCFUserNotificationNoteAlertLevel, NULL, NULL, NULL, (__bridge CFStringRef)Header, (__bridge CFStringRef)Message, NULL);
    return false;
}

- (Boolean)toggleBTConnection{
    if ([self getBluetoothDeviceInstance]) {
        if (self->_BTDev.isConnected) {
            //Turn off
            if ([self->_BTDev closeConnection] == kIOReturnSuccess) {
                // Close successful
                return true;
            }
            else {
                // false means error
                return false;
            }
        }
        else {
            //Turn on
            if ([self->_BTDev openConnection] == kIOReturnSuccess) {
                // Open successful
                return true;
            }
            else {
                return false;
            }
        }
    }
    else {
        // Failed to get IOBluetoothDevice instance of desired device
        return false;
    }
};

- (Boolean)getAudioID: (Boolean)showAlert {
    UInt32 dataSize;
    int numDevs;
    char devName[256];
    NSString *Message = @"Audio devices presented in the systems are:\n(Duplicated devices indicates Input and Output)\n";
    
    // Get number of devices
    AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize);
    numDevs = dataSize / sizeof(AudioDeviceID);
    AudioDeviceID DevID_list[numDevs];
    // Get devIDs
    AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize, DevID_list);

    // Looping thru all devices to get ID of the specified device
    for (int i = 0; i < numDevs; i++) {
        dataSize = sizeof(devName);
        // Get name of current device
        AudioObjectGetPropertyData(DevID_list[i], &devNameAddress, 0, NULL, &dataSize, devName);
        Message = [Message stringByAppendingFormat:@"\n➤  %s", devName];
        
        if (strcmp(self->_name, devName)==0) {
            UInt32 count;
            AudioObjectPropertyAddress checkIOAddress;
            checkIOAddress.mSelector = kAudioDevicePropertyStreams;
            
            // use dataSize to determine the type of current device
            checkIOAddress.mScope = kAudioDevicePropertyScopeInput;
            AudioObjectGetPropertyDataSize(DevID_list[i], &checkIOAddress, 0, NULL, &dataSize);
            count = dataSize / sizeof(AudioStreamID);
            
            if (count>0) {
                //is input device
                self->_AudioInputID = DevID_list[i];
            }
            
            checkIOAddress.mScope = kAudioDevicePropertyScopeOutput;
            AudioObjectGetPropertyDataSize(DevID_list[i], &checkIOAddress, 0, NULL, &dataSize);
            count = dataSize / sizeof(AudioStreamID);
            
            if (count>0) {
                //is output device
                self->_AudioOuputID = DevID_list[i];
            }
            
        }
    }
    
    // Get ID of default audio devices
    AudioDeviceID defaultInputID;
    AudioDeviceID defaultOutputID;
    UInt32 tmp_dataSize = sizeof(AudioDeviceID);
    
    AudioObjectGetPropertyData(kAudioObjectSystemObject, &devInAddress, 0, NULL, &tmp_dataSize, &defaultInputID);
    self->_CurrentAIID = defaultInputID;
    AudioObjectGetPropertyData(kAudioObjectSystemObject, &devOutAddress, 0, NULL, &tmp_dataSize, &defaultOutputID);
    self->_CurrentAOID = defaultOutputID;
    
    // return status
    if (self->_AudioInputID == 0 && self->_AudioOuputID == 0) {
        NSString *Header = [@"" stringByAppendingFormat:@"\"%@\" cannot be found or it's not connected", [NSString stringWithUTF8String: self->_name]];
        if (showAlert) {
            CFUserNotificationDisplayNotice(0, kCFUserNotificationNoteAlertLevel, NULL, NULL, NULL, (__bridge CFStringRef)Header, (__bridge CFStringRef)Message, NULL);}
        return false;
    }
    else {
        return true;
    }
};

- (Boolean)isCurrentAudioDevice {
    if (self->_AudioInputID == self->_CurrentAIID || self->_AudioOuputID == self->_CurrentAOID) {
        return true;
    }
    else {
        return false;
    }
}

- (Boolean) isAudioDeviceAvailable {
    return false;
}

- (Boolean)setAsActiveAudioDevice {
    OSStatus input_status = noErr;
    OSStatus output_status = noErr;
    AudioDeviceID InputID = self->_AudioInputID;
    AudioDeviceID OutputID = self->_AudioOuputID;
    
    // Set active device only if the ID is non-zero
    if (InputID != 0) {
        input_status = AudioObjectSetPropertyData(kAudioObjectSystemObject, &devInAddress, 0, NULL, sizeof(AudioDeviceID), &InputID);
    }
    
    if (OutputID != 0) {
        output_status = AudioObjectSetPropertyData(kAudioObjectSystemObject, &devOutAddress, 0, NULL, sizeof(AudioDeviceID), &OutputID);
    }

    if (input_status == noErr && output_status == noErr) {
        return true;
    }
    else {
        return false;
    }
};
@end
