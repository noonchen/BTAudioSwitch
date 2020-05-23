//
//  main.m
//  BTAudioSwitch
//
//  Created by Noon Chen on 2020/5/13.
//  Copyright © 2020 nochenon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTAudioSwitch.h"
#import "getopt.h"

void print_help() {
    printf("Usage: BTAudioSwitch <-switchOnly|-toggleOnly|-toggleSwitch> -devName=\"Device Name\"\n");
}

int main(int argc, const char * argv[]) {
    int opt = 0;
    Boolean toggleSwitch = false;
    Boolean toggleOnly = false;
    Boolean switchOnly = false;
    char *devName = "";
    
    struct option long_options[] =
    {
        {"toggleSwitch", no_argument, NULL, 'x'},
        {"toggleOnly", no_argument, NULL, 't'},
        {"switchOnly", no_argument, NULL, 's'},
        {"devName", required_argument, NULL, 'n'},
        {0, 0, 0, 0}
    };
    
    int long_index = 0;
    while ((opt = getopt_long_only(argc, argv, "", long_options, &long_index)) != -1) {
        switch (opt) {
            case 'x':
                toggleSwitch = true;
                break;
            case 't':
                toggleOnly = true;
                break;
            case 's':
                switchOnly = true;
                break;
            case 'n':
                devName = optarg;
                break;
            default:
                print_help();
                exit(EXIT_FAILURE);
        }
    };

    if (strcmp(devName, "") != 0) {
        // devName is given
        Device *Dev = [Device setName:devName];

        if (toggleSwitch == true && toggleOnly == false && switchOnly == false) {
            // See Readme for detailed description
            if ([Dev getBluetoothDeviceInstance]) {
                if (Dev->_BTDev.isConnected) {
                    // If BT device is connected
                    // Then we can get AudioID
                    [Dev getAudioID:true];
                    
                    if ([Dev isCurrentAudioDevice]) {
                        // If the device is the default audio device, toggle it off
                        [Dev toggleBTConnection];
                    }
                    else {
                        // If the device is not the default audio device, switch it as default audio device
                        [Dev setAsActiveAudioDevice];
                    }
                }
                else {
                    // If BT device is not connected
                    // Toggle to turn it on
                    if ([Dev toggleBTConnection]) {
                        /* Switch it as default audio device, but it takes some time for the audio device
                         to be available after connecting.
                         While loop to for detecting the availability.
                         A timer is also required to avoid dead loop.*/
                        Boolean audioDevAvailable = false;
                        // Timer
                        NSDate *start = [NSDate date];
                        NSTimeInterval Elapsed;
                        double timeout = 5;
                        
                        while (!audioDevAvailable) {
                            audioDevAvailable = [Dev getAudioID:false];
                            
                            Elapsed = fabs([start timeIntervalSinceNow]);
                            if(Elapsed > timeout) {
                                NSLog(@"Bluetooth connection timeout");
                                return 0;
                            }
                        }
                        [Dev setAsActiveAudioDevice];
                    }
                    else {
                        NSLog(@"Failed to connect BT device");
                    }
                }
            }
        }
        
        else if (toggleSwitch == false && toggleOnly == true && switchOnly == false) {
            // Toggle Bluetooth connection only, audio device is automatically handled by macOS
            [Dev toggleBTConnection];
        }
        
        else if (toggleSwitch == false && toggleOnly == false && switchOnly == true) {
            // Set the given device as the Input And Output audio device if possible
            if ([Dev getAudioID:true]) {
                [Dev setAsActiveAudioDevice];
            }
        }
        else {
            // Multiple function enabled
            NSLog(@"At least one and only one function argument should be enabled");
            print_help();
        }
    }
    else {
        // Argument "devName" is missing OR empty
        NSLog(@"Argument \"devName\" is required and cannot be empty");
        print_help();
    }
    return 0;
}
