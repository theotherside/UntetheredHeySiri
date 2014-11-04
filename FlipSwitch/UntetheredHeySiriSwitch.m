//
//  UntetheredHeySiriSwitch.m
//  UntetheredHeySiri
//
//  Created by Hamza Sood on 04/11/2014.
//  Copyright (c) 2014 Hamza Sood. All rights reserved.
//

#import "UntetheredHeySiriSwitch.h"
#import <notify.h>
@import VoiceTrigger;

@implementation UntetheredHeySiriSwitch {
    int _voiceTriggerNotificationToken;
}

- (id)init {
    if ((self = [super init])) {
        notify_register_dispatch(kVTPreferencesVoiceTriggerEnabledDidChangeDarwinNotification.UTF8String,
                                 &_voiceTriggerNotificationToken,
                                 dispatch_get_main_queue(), ^(int token) {
                                     [FSSwitchPanel.sharedPanel stateDidChangeForSwitchIdentifier:[[NSBundle bundleForClass:self.class]bundleIdentifier]];
                                 });
    }
    return self;
}

- (BOOL)switchWithIdentifierIsEnabled:(NSString *)switchIdentifier {
    return VTPreferences.sharedPreferences.voiceTriggerEnabled;
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
    return (VTPreferences.sharedPreferences.voiceTriggerEnabledWhenChargerDisconnected ? FSSwitchStateOn : FSSwitchStateOff);
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
    VTPreferences.sharedPreferences.voiceTriggerEnabledWhenChargerDisconnected = (newState == FSSwitchStateOn ? YES : NO);
    notify_post(kVTPreferencesVoiceTriggerEnabledDidChangeDarwinNotification.UTF8String);
}

- (void)dealloc {
    notify_cancel(_voiceTriggerNotificationToken);
    [super dealloc];
}

@end
